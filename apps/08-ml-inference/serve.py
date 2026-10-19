"""Demand forecast inference endpoint for the Northwind demo stack."""

from __future__ import annotations

from fastapi import FastAPI
from pydantic import BaseModel

from model_loader import load_model

app = FastAPI(title="northwind-demand-forecast")


class PredictRequest(BaseModel):
    sku: str
    features: dict[str, float]


@app.get("/healthz")
def healthz() -> dict[str, str]:
    model = load_model()
    return {"status": "ok", "model": model.name, "version": model.version}


@app.post("/v1/predict")
def predict(req: PredictRequest) -> dict[str, object]:
    model = load_model()
    return {
        "sku": req.sku,
        "model_version": model.version,
        "predicted_units": model.predict(req.features),
    }
