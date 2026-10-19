"""Loads the demand-forecast coefficients from disk."""

from __future__ import annotations

import json
import os
from dataclasses import dataclass
from functools import lru_cache
from pathlib import Path

DEFAULT_MODEL_PATH = Path(os.environ.get("MODEL_PATH", "/models/demand-forecast.json"))


@dataclass(frozen=True)
class Model:
    name: str
    version: str
    intercept: float
    coefficients: dict[str, float]

    def predict(self, features: dict[str, float]) -> float:
        total = self.intercept
        for key, weight in self.coefficients.items():
            total += weight * float(features.get(key, 0.0))
        return round(total, 4)


@lru_cache(maxsize=1)
def load_model(path: Path = DEFAULT_MODEL_PATH) -> Model:
    payload = json.loads(path.read_text(encoding="utf-8"))
    return Model(
        name=payload["name"],
        version=payload["version"],
        intercept=float(payload["intercept"]),
        coefficients={k: float(v) for k, v in payload["coefficients"].items()},
    )
