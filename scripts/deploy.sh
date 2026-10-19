#!/usr/bin/env bash
#
# DEMO FIXTURE. Upstream images on purpose. See ../README.md.
#
# Same asymmetry as infra/main.tf: Image Suggestions reports the images in this
# file but offers no one-click change, and migration does not read it at all.

set -euo pipefail

NAMESPACE="${NAMESPACE:-northwind}"
ENVIRONMENT="${1:-staging}"

log() { printf '==> %s\n' "$*"; }

log "Planning infrastructure for ${ENVIRONMENT}"
docker run --rm \
  -v "$PWD/infra:/workspace" \
  -w /workspace \
  hashicorp/terraform:1.9 plan -out=tfplan

log "Rendering manifests"
docker run --rm \
  -v "$PWD/deploy:/workspace" \
  -w /workspace \
  bitnami/kubectl:1.31 kustomize ./k8s

log "Applying manifests to ${NAMESPACE}"
docker run --rm \
  -v "$HOME/.kube:/.kube:ro" \
  -v "$PWD/deploy:/workspace" \
  -w /workspace \
  bitnami/kubectl:1.31 apply -n "${NAMESPACE}" -f ./k8s

log "Running smoke tests"
docker run --rm --network host \
  curlimages/curl:8.10.1 \
  --fail --silent --show-error "http://localhost:8080/healthz"

log "Deploy to ${ENVIRONMENT} complete"
