import os
import requests
import json
from flask import Flask, render_template, request, redirect, url_for, flash, abort, session
from flask_wtf.csrf import CSRFProtect
from flask_session import Session
from email_validator import validate_email, EmailNotValidError
import redis

app = Flask(__name__)

# =========================
# Security / hardening
# =========================

# Enforce Host header (ALB + Route53 expected hostnames)
ALLOWED_HOSTS = {
    "cafe.ryan-lab.com",
    "www.cafe.ryan-lab.com",
}

@app.before_request
def enforce_host_header():
    # allow health checks regardless
    if request.path == "/health":
        return
    host_header = request.headers.get("Host", "")
    hostname = host_header.split(":", 1)[0]

    if hostname not in ALLOWED_HOSTS:
        abort(400, "Invalid host header")

@app.after_request
def set_security_headers(response):
    response.headers["Strict-Transport-Security"] = "max-age=31536000; includeSubDomains; preload"
    response.headers["X-Content-Type-Options"] = "nosniff"
    response.headers["X-Frame-Options"] = "DENY"
    response.headers["X-XSS-Protection"] = "1; mode=block"
    response.headers["Referrer-Policy"] = "strict-origin-when-cross-origin"
    response.headers["Content-Security-Policy"] = (
        "default-src 'self'; "
        "img-src 'self' data:; "
        "style-src 'self' 'unsafe-inline';"
    )
    return response

# =========================
# App config / CSRF
# =========================

# In ECS you will load this from Secrets Manager and inject as env var FLASK_SECRET_KEY.
# For local dev, this fallback prevents hard failure.
app.config["SECRET_KEY"] = os.getenv("FLASK_SECRET_KEY", "dev-only-change-me")

# Redis session configuration
REDIS_HOST = os.getenv("REDIS_HOST", "localhost")
REDIS_PORT = int(os.getenv("REDIS_PORT", "6379"))

try:
    redis_client = redis.Redis(
        host=REDIS_HOST,
        port=REDIS_PORT,
        socket_connect_timeout=5,
        socket_timeout=5
    )
    # Test connection
    redis_client.ping()
    
    # Configure Flask-Session to use Redis
    app.config["SESSION_TYPE"] = "redis"
    app.config["SESSION_REDIS"] = redis_client
    app.config["SESSION_PERMANENT"] = False
    app.config["SESSION_USE_SIGNER"] = True
    Session(app)
    
    REDIS_AVAILABLE = True
    print("Redis connected successfully")
except (redis.ConnectionError, redis.TimeoutError, redis.ResponseError) as e:
    print(f"Redis unavailable, falling back to client-side sessions: {e}")
    REDIS_AVAILABLE = False
    redis_client = None

csrf = CSRFProtect(app)

# Orders service discovery base URL (ECS uses Cloud Map name)
ORDERS_BASE_URL = os.getenv("ORDERS_BASE_URL", "http://orders.cafe.local:5001")
ORDERS_TIMEOUT_SEC = float(os.getenv("ORDERS_TIMEOUT_SEC", "5.0"))

# =========================
# Menu data (Original Menu)
# =========================

COFFEES = [
    {"flavor": "French Vanilla", "price": 3.00},
    {"flavor": "Caramel Frappuccino", "price": 3.75},
    {"flavor": "Pumpkin Spice", "price": 3.50},
    {"flavor": "Hazelnut", "price": 4.00},
    {"flavor": "Mocha", "price": 4.50},
]

DESSERTS = [
    {"name": "Donut", "price": 1.50},
    {"name": "Cherry Pie", "price": 2.75},
    {"name": "Strawberry Cheesecake", "price": 3.00},
    {"name": "Cinnamon Roll", "price": 2.50},
]

# Authoritative price map (UI-side validation)
MENU = {item["flavor"]: item["price"] for item in COFFEES}
MENU.update({item["name"]: item["price"] for item in DESSERTS})

# =========================
# Helper: Menu caching
# =========================

def get_cached_menu():
    """Get menu from Redis cache or fallback to in-memory."""
    if not REDIS_AVAILABLE or redis_client is None:
        return {"coffees": COFFEES, "desserts": DESSERTS}
    
    try:
        # Try to get from cache
        cached = redis_client.get("menu:data")
        if cached:
            return json.loads(cached)
        
        # Cache miss - store for 1 hour
        menu_data = {"coffees": COFFEES, "desserts": DESSERTS}
        redis_client.setex("menu:data", 3600, json.dumps(menu_data))
        return menu_data
    except (redis.ConnectionError, redis.TimeoutError):
        return {"coffees": COFFEES, "desserts": DESSERTS}

# =========================
# Routes
# =========================

@app.get("/health")
def health():
    redis_status = "connected" if REDIS_AVAILABLE else "unavailable"
    return {"service": "web_frontend", "status": "ok", "redis": redis_status}, 200

@app.route("/")
def index():
    # Track page views in session (demonstrates Redis session storage)
    session["page_views"] = session.get("page_views", 0) + 1
    
    # Get menu from cache
    menu_data = get_cached_menu()
    return render_template(
        "index.html",
        coffees=menu_data["coffees"],
        desserts=menu_data["desserts"]
    )

@app.route("/order", methods=["POST"])
def place_order():
    customer_name = request.form.get("customer_name", "").strip()
    customer_email = request.form.get("customer_email", "").strip()
    items = request.form.getlist("order_items")

    # Validate name
    if not customer_name or len(customer_name) > 100:
        flash("Please provide a valid customer name (1-100 characters).")
        return redirect(url_for("index"))

    # Validate email
    try:
        valid = validate_email(customer_email)
        customer_email = valid.email
    except EmailNotValidError:
        flash("Please provide a valid email address.")
        return redirect(url_for("index"))

    if not items:
        flash("Please select at least one item.")
        return redirect(url_for("index"))

    # Parse form payload (your existing HTML format)
    order_details = []
    total = 0.0

    try:
        for val in items:
            parts = val.split("||")
            if len(parts) != 2:
                raise ValueError("Invalid item format")
            category, name = parts

            # Prevent tampering: validate item name and look up price here too (UI-side)
            if name not in MENU:
                raise ValueError(f"Unknown item: {name}")
            price = float(MENU[name])

            qty_key = "qty_" + name.replace(" ", "_")
            qty = request.form.get(qty_key, "1")
            if not qty.isdigit() or int(qty) <= 0:
                raise ValueError(f"Invalid quantity for {name}")
            qty = int(qty)

            subtotal = price * qty
            total += subtotal
            order_details.append((category, name, price, qty, subtotal))

    except (ValueError, TypeError) as e:
        flash(f"Error processing order: {str(e)}")
        return redirect(url_for("index"))

    # Build JSON payload for orders_service (NO PRICES SENT)
    payload = {
        "customer_name": customer_name,
        "customer_email": customer_email,
        "items": [
            {"category": cat, "name": name, "quantity": qty}
            for (cat, name, _price, qty, _subtotal) in order_details
        ],
    }

    # Call orders_service
    try:
        r = requests.post(
            f"{ORDERS_BASE_URL}/orders",
            json=payload,
            timeout=ORDERS_TIMEOUT_SEC,
        )
        r.raise_for_status()
        data = r.json()
    except requests.RequestException as e:
        flash(f"Order service unavailable. Please try again. ({e})")
        return redirect(url_for("index"))
    except ValueError:
        flash("Order service returned an invalid response.")
        return redirect(url_for("index"))

    # Expect authoritative response from orders_service
    order_id = data.get("order_id")
    order_time = data.get("order_time")
    order_time_iso = data.get("order_time_iso")

    authoritative_total_raw = data.get("total")
    if authoritative_total_raw is None:
        authoritative_total_raw = data.get("total_amount")

    try:
        authoritative_total = float(authoritative_total_raw)
    except (TypeError, ValueError):
        flash("Order service returned an invalid total.")
        return redirect(url_for("index"))

    if order_id is None or authoritative_total is None:
        flash("Order service response missing required fields.")
        return redirect(url_for("index"))

    return render_template(
        "confirmation.html",
        order_id=order_id,
        items=order_details,          # fine for display
        total=authoritative_total,    # backend total is source of truth
        order_time=order_time,
        order_time_iso=order_time_iso,
    )

if __name__ == "__main__":
    # Local dev only. In ECS/Docker we run gunicorn (see Dockerfile CMD).
    debug = os.getenv("FLASK_DEBUG", "false").lower() == "true"
    app.run(host="0.0.0.0", port=int(os.getenv("PORT", "5000")), debug=debug)
