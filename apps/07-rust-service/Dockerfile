# DEMO FIXTURE. The base images below are deliberately upstream Docker Hub
# images. This file is the "before" state that Guardener migrates. Don't copy it
# as a reference architecture. See ../../README.md.
#
# Tier: intermediate. The most common real-world blocker: the runtime stage
# still needs apt-get for CA certificates.
# Expected: both stages get a comment only. Neither is eligible for a one-click
# change, because each one runs commands with RUN.

FROM rust:1.82 AS build

WORKDIR /src

COPY Cargo.toml ./
COPY src ./src

RUN cargo build --release --locked || cargo build --release

FROM debian:bookworm-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY --from=build /src/target/release/telemetry /usr/local/bin/telemetry

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/telemetry"]
