# DEMO FIXTURE. The base images below are deliberately upstream Docker Hub
# images. This file is the "before" state that Guardener migrates. Don't copy it
# as a reference architecture. See ../../README.md.
#
# Tier: complex. The base image is assembled from a build argument.
# Expected: Guardener substitutes the ARG default and still identifies
# python:3.11-slim, so it reports a replacement. It will not offer a one-click
# change, because the FROM line is not a single literal value.

ARG PYTHON_VERSION=3.11

FROM python:${PYTHON_VERSION}-slim AS deps

WORKDIR /app

COPY requirements.txt ./
RUN pip install --no-cache-dir --target=/deps -r requirements.txt

FROM python:${PYTHON_VERSION}-slim

ENV PYTHONPATH=/deps \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    MODEL_PATH=/models/demand-forecast.json

WORKDIR /app

COPY --from=deps /deps /deps
COPY models/ /models/
COPY serve.py model_loader.py ./

EXPOSE 8501

ENTRYPOINT ["python", "-m", "uvicorn", "serve:app", "--host", "0.0.0.0", "--port", "8501"]
