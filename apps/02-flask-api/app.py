"""Order intake API for the Northwind demo stack."""

import os
import uuid

from flask import Flask, jsonify, request

app = Flask(__name__)

_ORDERS: dict[str, dict] = {}


@app.get("/healthz")
def healthz():
    return jsonify(status="ok", service="flask-api")


@app.get("/api/orders")
def list_orders():
    return jsonify(orders=list(_ORDERS.values()), count=len(_ORDERS))


@app.post("/api/orders")
def create_order():
    payload = request.get_json(silent=True) or {}
    if "sku" not in payload:
        return jsonify(error="sku is required"), 400

    order_id = str(uuid.uuid4())
    order = {
        "id": order_id,
        "sku": payload["sku"],
        "quantity": int(payload.get("quantity", 1)),
    }
    _ORDERS[order_id] = order
    return jsonify(order), 201


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(os.environ.get("PORT", 8000)))
