import json
import os
import boto3
from botocore.exceptions import ClientError

SES_REGION = os.getenv("SES_REGION", "us-east-1")
FROM_EMAIL = os.getenv("FROM_EMAIL")  # e.g. "orders@cafe.ryanb-lab.com"
REPLY_TO = os.getenv("REPLY_TO")      # optional
APP_NAME = os.getenv("APP_NAME", "Ryan's Cafe")

ses = boto3.client("ses", region_name=SES_REGION)

def _build_email(order: dict) -> tuple[str, str, list[str]]:
    """
    Expected order payload (JSON):
    {
      "event_type": "order_created",
      "order_id": 123,
      "customer_name": "Ryan",
      "customer_email": "customer@example.com",
      "order_time_utc": "2025-12-21 12:34:56",
      "total_amount": "9.00",
      "items": [
        {"item_name":"Mocha","quantity":2,"unit_price":"4.50","subtotal":"9.00"}
      ]
    }
    """
    to_email = order.get("customer_email")
    customer_name = order.get("customer_name", "Customer")
    order_id = order.get("order_id")
    order_time = order.get("order_time_utc")
    items = order.get("items", [])
    total = order.get("total_amount")

    if not to_email:
        raise ValueError("Missing customer_email in order payload")

    lines = []
    for it in items:
        name = it.get("item_name", "Item")
        qty = it.get("quantity", 1)
        unit_price = it.get("unit_price", 0)
        subtotal = it.get("subtotal", 0)
        lines.append(f"- {name} ({qty} x ${float(unit_price):.2f}) = ${float(subtotal):.2f}")

    items_block = "\n".join(lines) if lines else "- (no items listed)"

    subject = f"{APP_NAME} - Order Confirmation"
    text_body = (
        f"Hi {customer_name},\n\n"
        f"Thank you for your order at {APP_NAME}!\n\n"
        f"Order ID: {order_id}\n"
        f"Order Time: {order_time}\n\n"
        f"Order Summary:\n{items_block}\n\n"
        f"Total: ${float(total):.2f}\n\n"
        f"Best regards,\n{APP_NAME}\n"
    )

    reply_to_list = [REPLY_TO] if REPLY_TO else []
    return subject, text_body, reply_to_list

def _send_email(to_email: str, subject: str, body_text: str, reply_to_list: list[str]) -> None:
    if not FROM_EMAIL:
        raise ValueError("FROM_EMAIL env var is required")

    params = {
        "Source": FROM_EMAIL,
        "Destination": {"ToAddresses": [to_email]},
        "Message": {
            "Subject": {"Data": subject, "Charset": "UTF-8"},
            "Body": {"Text": {"Data": body_text, "Charset": "UTF-8"}},
        },
    }
    if reply_to_list:
        params["ReplyToAddresses"] = reply_to_list

    ses.send_email(**params)

def lambda_handler(event, context):
    # Enable partial batch response so one bad message doesn't re-drive the entire batch
    failures = []

    records = event.get("Records", [])
    for r in records:
        msg_id = r.get("messageId")
        try:
            body = r.get("body", "")
            order = json.loads(body) if body else {}
            subject, text_body, reply_to_list = _build_email(order)
            to_email = order["customer_email"]
            _send_email(to_email, subject, text_body, reply_to_list)
        except (ValueError, json.JSONDecodeError, ClientError) as e:
            # Mark this message as failed so it gets retried; DLQ handles poison messages after maxReceiveCount
            failures.append({"itemIdentifier": msg_id})

    return {"batchItemFailures": failures}
