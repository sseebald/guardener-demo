# DEMO FIXTURE. The base image below is deliberately an upstream Docker Hub
# image. This file is the "before" state that Guardener migrates. Don't copy it
# as a reference architecture. See ../../README.md.
#
# Tier: easy. Single stage that installs packages with RUN.
# Expected: Guardener names the replacement but withholds the one-click change,
# because swapping the base out from under a RUN can break the build.

FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py ./

EXPOSE 8000

ENTRYPOINT ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "2", "app:app"]
