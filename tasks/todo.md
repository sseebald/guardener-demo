# guardener-demo build log

## Goal

Stand up a public repo under `sseebald` full of realistic, deliberately
un-migrated Dockerfiles so Guardener's Container Image Suggestions and Container
Image Migration have something real to act on, and so the Insights dashboard has
a repo to report against.

## Plan

- [x] Pull the real `.chainguard/` schemas from the Guardener docs rather than
      writing config from memory
- [x] Confirm `gh` auth (`sseebald`) and Docker availability
- [x] Build 11 Dockerfiles spanning easy to complex, each one mapped to a
      distinct Guardener outcome
- [x] Add the non-Dockerfile surfaces: Compose, k8s manifests, Helm values,
      Terraform, shell, Makefile
- [x] Write `.chainguard/images.yaml` using only documented keys
- [x] Validate: `docker build --check` on every Dockerfile, real builds on the
      lightweight ones, YAML parse on every manifest
- [x] Commit 1 to `main`: app code, no `.chainguard/`
- [x] Commit 2 to `main`: add `.chainguard/images.yaml` (this push starts the
      first migration run)
- [x] Branch + PR adding `apps/12-worker` to trigger Image Suggestions

## Design notes

### Why the Dockerfiles use upstream images

Our standing policy prefers `cgr.dev/chainguard/*` for new image references.
This repo inverts that deliberately. Guardener has nothing to suggest about a
repo that already uses Chainguard images, so the upstream references are the
test fixture. Every Dockerfile carries a header comment saying so.

### Why the commit order matters

| | Suggestions | Migration |
| --- | --- | --- |
| Reads | lines a PR adds/changes | whole default branch |
| Config from | PR's base branch | default branch |
| Fires on | PR opened / ready | push touching `images.yaml`, then every `period` |

A PR that *adds* `.chainguard/images.yaml` gets no suggestions on itself. So the
config lands on `main` first (commit 2), and only then does the demo PR go up.

### One-click eligibility

Needs a single literal image on its own line, the org already holding the
replacement at a matching tag, a version-preserving replacement, and a stage
(plus anything built `FROM` it) with no `RUN`, no shell-form `CMD`/`ENTRYPOINT`,
no `ONBUILD`, and no `CMD` without `ENTRYPOINT`. The Dockerfiles are
deliberately split across both sides of that line.

## Review

See the "Verification" section below for what was actually tested versus what
was only syntax-checked. Nothing here is claimed as verified unless a tool
confirmed it.

## Sources

- [Configuring Guardener](https://edu.chainguard.dev/chainguard/guardener/github/configuration/)
- [Container Image Suggestions](https://edu.chainguard.dev/chainguard/guardener/github/image-suggestions/)
- [Container Image Migration](https://edu.chainguard.dev/chainguard/guardener/github/image-migration/)
- [Hardened Actions](https://edu.chainguard.dev/chainguard/guardener/github/actions-security/)
- [Commit Verification](https://edu.chainguard.dev/chainguard/guardener/github/commit-verification/)
