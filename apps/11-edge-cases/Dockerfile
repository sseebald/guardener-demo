# DEMO FIXTURE. The references below are deliberately upstream and deliberately
# awkward. This file exists to exercise the cases Guardener documents as
# skipped or "Not migrated", so the demo shows the honest edges of the feature
# and not just the happy path. See ../../README.md.
#
# Tier: complex. Four stages, four different outcomes.
#
# NOTE: this file needs a build argument to build at all:
#   docker build --build-arg RUNTIME_BASE=alpine:3.20 apps/11-edge-cases

# Declared before the first FROM so it lands in global scope. An ARG declared
# after a FROM belongs to that build stage and a later FROM cannot see it.
# Deliberately given no default value: see stage 4.
ARG RUNTIME_BASE

# ---------------------------------------------------------------------------
# 1. FROM scratch. There is no upstream image to replace, so Guardener skips it.
# ---------------------------------------------------------------------------
FROM scratch AS config

COPY rootfs/etc/northwind/agent.yaml /etc/northwind/agent.yaml

# ---------------------------------------------------------------------------
# 2. Pinned by digest with no tag. Guardener reports the reference but leaves it
#    unchanged: with no tag there is no version to carry over to the
#    replacement, so the only available swap would be `latest`.
#
#    This digest is the real index digest for redis:7-alpine, resolved with
#    `docker buildx imagetools inspect redis:7-alpine`.
# ---------------------------------------------------------------------------
FROM redis@sha256:858f009f9709ce576febc734aa78b8f6d624b82571f9ddb6bda4377c833b3499 AS cache

# ---------------------------------------------------------------------------
# 3. A FROM that names an earlier build stage. Guardener skips stage references,
#    because there is no registry image on this line.
# ---------------------------------------------------------------------------
FROM cache AS cache-tuned

COPY rootfs/etc/redis/redis.conf /usr/local/etc/redis/redis.conf

# ---------------------------------------------------------------------------
# 4. A FROM built from an ARG with no default (declared at the top of this
#    file). Guardener skips references it cannot resolve, unlike
#    apps/08-ml-inference where the ARG does have a default to substitute. The
#    trailing CMD without an ENTRYPOINT would block a one-click change on its
#    own.
# ---------------------------------------------------------------------------
FROM ${RUNTIME_BASE} AS runtime

COPY --from=config /etc/northwind/agent.yaml /etc/northwind/agent.yaml
COPY --from=cache-tuned /usr/local/etc/redis/redis.conf /etc/northwind/redis.conf

EXPOSE 7070

CMD ["northwind-agent", "--config", "/etc/northwind/agent.yaml"]
