# DEMO FIXTURE. The base images below are deliberately upstream Docker Hub
# images. See ../../README.md.
#
# This app exists to demonstrate Container Image Suggestions specifically.
# Suggestions only reads lines a pull request adds or changes, and it reads its
# config from the base branch, so this file has to arrive through a PR opened
# after .chainguard/images.yaml is already on main.
#
# Expected: a comment on the deps stage (it has a RUN), and a one-click
# suggested change on the runtime stage, which is a single literal image, has
# no RUN, and uses an exec-form ENTRYPOINT.

FROM python:3.12-slim AS deps

WORKDIR /app

COPY requirements.txt ./
RUN pip install --no-cache-dir --target=/deps -r requirements.txt

FROM python:3.12-slim

ENV PYTHONPATH=/deps \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

COPY --from=deps /deps /deps
COPY worker.py ./

ENTRYPOINT ["python", "worker.py"]
