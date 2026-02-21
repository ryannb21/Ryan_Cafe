import os
import json
import re
import logging
from datetime import datetime, timezone
from decimal import Decimal, ROUND_HALF_UP
from typing import Any, Dict, Optional, List

import boto3
import mysql.connector
from flask import Flask, request

app = Flask(__name__)

LOG_LEVEL = os.getenv("LOG_LEVEL", "INFO").upper()
logging.basicConfig(level=LOG_LEVEL, format="%(asctime)s %(levelname)s %(message)s")
logger = logging.getLogger("orders-service")

AWS_REGION = os.getenv("AWS_REGION", "us-east-1")
_secrets_client = boto3.client("secretsmanager", region_name=AWS_REGION)
_sqs_client = boto3.client("sqs", region_name=AWS_REGION)

_DB_SECRET_CACHE: Optional[Dict[str, str]] = None
_SQS_QUEUE_URL_CACHE: Optional[str] = None
_SCHEMA_READY: bool = False


# =========================
# Authoritative menu (server-side prices)
# MUST match your web menu items by name
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
MENU: Dict[str, Decimal] = {i["flavor"]: Decimal(str(i["price"])) for i in COFFEES}
MENU.update({i["name"]: Decimal(str(i["price"])) for i in DESSERTS})


@app.get("/health")
def health():
    # Light readiness check: DB connect only (fast)
    try:
        conn = _db_connect(use_database=True)
        conn.close()
        return {"service": "orders", "status": "ok"}, 200
    except Exception as e:
        logger.warning("Health DB check failed: %s", e)
        return {"service": "orders", "status": "degraded"}, 503


def _require_env(name: str) -> str:
    val = os.getenv(name)
    if not val:
        raise RuntimeError(f"Missing required environment variable: {name}")
    return val


def _basic_email_ok(email: str) -> bool:
    return bool(re.match(r"^[^@\s]+@[^@\s]+\.[^@\s]+$", email or ""))


def _money(x: Any) -> Decimal:
    d = Decimal(str(x))
    return d.quantize(Decimal("0.01"), rounding=ROUND_HALF_UP)


def _get_db_secret() -> Dict[str, str]:
    """
    Expected secret JSON:
      {"host":"...","user":"...","password":"...","database":"cafe_orders"}
    """
    global _DB_SECRET_CACHE
    if _DB_SECRET_CACHE:
        return _DB_SECRET_CACHE

    secret_name = _require_env("DB_SECRET_NAME")
    resp = _secrets_client.get_secret_value(SecretId=secret_name)
    secret_str = resp.get("SecretString")
    if not secret_str:
        raise RuntimeError("DB secret has no SecretString")

    secret = json.loads(secret_str)
    for k in ("host", "user", "password", "database"):
        if k not in secret or not secret[k]:
            raise RuntimeError(f"DB secret missing required key: {k}")

    _DB_SECRET_CACHE = {
        "host": secret["host"],
        "user": secret["user"],
        "password": secret["password"],
        "database": secret["database"],
    }
    return _DB_SECRET_CACHE


def _db_connect(*, use_database: bool):
    s = _get_db_secret()
    kwargs = dict(
        host=s["host"],
        user=s["user"],
        password=s["password"],
        connection_timeout=5,
    )
    if use_database:
        kwargs["database"] = s["database"]
    return mysql.connector.connect(**kwargs)


def _ensure_database_and_schema() -> None:
    """
    Creates database (if missing) and tables.
    Mirrors your original schema.
    """
    global _SCHEMA_READY
    if _SCHEMA_READY:
        return

    s = _get_db_secret()
    db_name = s["database"]

    # Basic DB name sanity check
    if not re.match(r"^[a-zA-Z0-9_]+$", db_name):
        raise RuntimeError("Invalid database name in secret")

    # 1) Ensure DB exists
    conn = _db_connect(use_database=False)
    try:
        cur = conn.cursor()
        cur.execute(f"CREATE DATABASE IF NOT EXISTS {db_name}")
        conn.commit()
    finally:
        try:
            cur.close()
        except Exception:
            pass
        conn.close()

    # 2) Ensure tables exist
    conn2 = _db_connect(use_database=True)
    try:
        cur2 = conn2.cursor()
        cur2.execute(
            """
            CREATE TABLE IF NOT EXISTS orders (
              id INT AUTO_INCREMENT PRIMARY KEY,
              order_time DATETIME NOT NULL,
              total_amount DECIMAL(7,2) NOT NULL
            )
            """
        )
        cur2.execute(
            """
            CREATE TABLE IF NOT EXISTS order_items (
              id INT AUTO_INCREMENT PRIMARY KEY,
              customer_name VARCHAR(100),
              customer_email VARCHAR(100),
              order_id INT NOT NULL,
              category VARCHAR(50),
              item_name VARCHAR(100),
              unit_price DECIMAL(5,2),
              quantity INT,
              subtotal DECIMAL(7,2),
              FOREIGN KEY (order_id) REFERENCES orders(id)
            )
            """
        )
        conn2.commit()
        _SCHEMA_READY = True
    finally:
        try:
            cur2.close()
        except Exception:
            pass
        conn2.close()


def _get_queue_url() -> str:
    """
    Accept either env var name to avoid mismatches.
    Prefer URL if provided.
    """
    global _SQS_QUEUE_URL_CACHE
    if _SQS_QUEUE_URL_CACHE:
        return _SQS_QUEUE_URL_CACHE

    # Your Terraform currently used ORDERS_EVENTS_QUEUE_URL
    queue_url = os.getenv("ORDERS_EVENTS_QUEUE_URL") or os.getenv("ORDER_EVENTS_QUEUE_URL")
    if queue_url:
        _SQS_QUEUE_URL_CACHE = queue_url
        return queue_url

    queue_name = os.getenv("ORDER_EVENTS_QUEUE_NAME") or os.getenv("ORDERS_EVENTS_QUEUE_NAME")
    if not queue_name:
        raise RuntimeError("Missing queue URL or queue NAME environment variable")
    resp = _sqs_client.get_queue_url(QueueName=queue_name)
    _SQS_QUEUE_URL_CACHE = resp["QueueUrl"]
    return _SQS_QUEUE_URL_CACHE


def _publish_order_event(event: Dict[str, Any]) -> None:
    queue_url = _get_queue_url()
    _sqs_client.send_message(QueueUrl=queue_url, MessageBody=json.dumps(event))


@app.post("/orders")
def create_order():
    """
    Expected JSON (from your current web_frontend):
    {
      "customer_name": "...",
      "customer_email": "...",
      "items": [
        {"category":"coffee", "name":"Mocha", "quantity":2},
        {"category":"dessert", "name":"Donut", "quantity":1}
      ]
    }

    Note:
    - No price is accepted from the client.
    - We compute price from MENU map here.
    """
    try:
        _ensure_database_and_schema()

        payload = request.get_json(silent=True) or {}
        customer_name = (payload.get("customer_name") or "").strip()
        customer_email = (payload.get("customer_email") or "").strip()
        items = payload.get("items")

        if not customer_name:
            return {"error": "customer_name is required"}, 400
        if not customer_email or not _basic_email_ok(customer_email):
            return {"error": "valid customer_email is required"}, 400
        if not isinstance(items, list) or len(items) == 0:
            return {"error": "items must be a non-empty list"}, 400

        normalized_items: List[Dict[str, Any]] = []
        total_amount = Decimal("0.00")

        for i, item in enumerate(items):
            if not isinstance(item, dict):
                return {"error": f"items[{i}] must be an object"}, 400

            category = (item.get("category") or "").strip()

            # Accept either "name" (web) or "item_name" (legacy compatibility)
            name = (item.get("name") or item.get("item_name") or "").strip()

            quantity = item.get("quantity")

            if not category or not name:
                return {"error": f"items[{i}] category and name are required"}, 400

            if name not in MENU:
                return {"error": f"items[{i}] unknown item name: {name}"}, 400

            try:
                qty = int(quantity)
                if qty <= 0:
                    raise ValueError()
            except Exception:
                return {"error": f"items[{i}] quantity must be a positive integer"}, 400

            unit_price = MENU[name]
            subtotal = _money(unit_price * qty)
            total_amount = _money(total_amount + subtotal)

            normalized_items.append({
                "category": category,
                "item_name": name,
                "unit_price": str(_money(unit_price)),
                "quantity": qty,
                "subtotal": str(subtotal),
            })

        now_utc = datetime.now(timezone.utc)
        order_time_str = now_utc.strftime("%Y-%m-%d %H:%M:%S")
        order_time_iso = now_utc.isoformat()

        conn = _db_connect(use_database=True)
        try:
            conn.autocommit = False
            cur = conn.cursor()

            # 1) Insert into orders
            cur.execute(
                "INSERT INTO orders (order_time, total_amount) VALUES (%s, %s)",
                (order_time_str, str(total_amount)),
            )
            order_id = cur.lastrowid

            # 2) Insert into order_items
            cur.executemany(
                """
                INSERT INTO order_items
                  (customer_name, customer_email, order_id, category, item_name, unit_price, quantity, subtotal)
                VALUES
                  (%s, %s, %s, %s, %s, %s, %s, %s)
                """,
                [
                    (
                        customer_name,
                        customer_email,
                        order_id,
                        it["category"],
                        it["item_name"],
                        it["unit_price"],
                        it["quantity"],
                        it["subtotal"],
                    )
                    for it in normalized_items
                ],
            )

            conn.commit()

        except Exception:
            conn.rollback()
            raise
        finally:
            try:
                cur.close()
            except Exception:
                pass
            conn.close()

        # Publish event for Lambda -> SES
        event = {
            "event_type": "order_created",
            "order_id": int(order_id),
            "customer_name": customer_name,
            "customer_email": customer_email,
            "order_time_utc": order_time_str,
            "total_amount": str(total_amount),
            "items": normalized_items,
        }
        _publish_order_event(event)

        # Response contract for web_frontend
        return {
            "order_id": int(order_id),
            "total": float(total_amount),
            "order_time": order_time_str,
            "order_time_iso": order_time_iso,
        }, 201

    except RuntimeError as e:
        logger.exception("Config/runtime error")
        return {"error": str(e)}, 500
    except Exception:
        logger.exception("Unhandled error creating order")
        return {"error": "internal server error"}, 500


if __name__ == "__main__":
    # Local dev only. In ECS/Docker we run gunicorn (see Dockerfile CMD).
    debug = os.getenv("FLASK_DEBUG", "false").lower() == "true"
    app.run(host="0.0.0.0", port=int(os.getenv("PORT", "5001")), debug=True)
