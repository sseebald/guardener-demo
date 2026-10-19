# DEMO FIXTURE. The base images below are deliberately upstream Docker Hub
# images. This file is the "before" state that Guardener migrates. Don't copy it
# as a reference architecture. See ../../README.md.
#
# Tier: intermediate. Two stages with different outcomes.
# Expected: the build stage gets a comment only (it has a RUN), while the
# runtime stage is clean enough for a one-click suggested change.

FROM golang:1.23 AS build

WORKDIR /src

COPY go.mod ./
COPY main.go ./

RUN CGO_ENABLED=0 GOOS=linux go build -trimpath -o /out/inventory .

FROM alpine:3.20

COPY --from=build /out/inventory /usr/local/bin/inventory

EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/inventory"]
