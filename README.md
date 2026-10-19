# guardener-demo

A deliberately un-migrated application repo, built as a live fixture for
[Chainguard Guardener](https://edu.chainguard.dev/chainguard/guardener/github/configuration/).

Eleven Dockerfiles plus the usual pile of Kubernetes manifests, Compose files,
Helm values, Terraform and shell scripts that a real platform team accumulates.
Every base image in here is upstream: Docker Hub, MCR, that kind of thing.

## Read this before you copy anything

**Everything in this repo is the "before" picture on purpose.** The upstream
images are the fixture. Guardener has nothing to say about a repo that already
uses `cgr.dev/chainguard/*`, so to show the product working you need a repo that
doesn't. The Chainguard end state is whatever Guardener produces in its
migration pull request, and that PR is the demo.

Don't clone this as a reference architecture. Clone the output.

## What's wired up

| Feature | Config | State |
| --- | --- | --- |
| Container Image Suggestions | `.chainguard/images.yaml` | on |
| Container Image Migration | `.chainguard/images.yaml` (`migrate` block) | on, 24h period |
| Hardened Actions | `.chainguard/actions.yaml` | not configured |
| Commit Verification | `.chainguard/source.yaml` | not configured |

```yaml
# .chainguard/images.yaml
enabled: true
prefer_fips: false
migrate:
  enabled: true
  period: "24h"
  ignore:
    files:
      - "Dockerfile.dev"
    images:
      - "busybox:*"
```

## The two features read this repo in opposite directions

This is the thing worth internalizing before you demo it, because it decides
what you push and in what order.

| | Image Suggestions | Image Migration |
| --- | --- | --- |
| Reads | only lines a PR **adds or changes** | the **whole default branch** |
| Reads config from | the PR's **base branch** | the **default branch** |
| Fires on | a PR being opened or marked ready | a push touching `.chainguard/images.yaml`, then every `migrate.period` |
| Output | inline review comments, non-blocking | one maintained PR, "Migrate container images to Chainguard equivalents" |
| Reads Terraform / shell / Make? | reports them, no suggestion | no, never |

The practical consequence: **a PR that adds `.chainguard/images.yaml` gets no
suggestions on itself.** The config has to already be on `main`. The git history
here is ordered accordingly.

## The expected-behavior matrix

Each Dockerfile is here to trip a different branch of Guardener's decision tree,
so the demo shows the real shape of the feature instead of eleven copies of the
same comment.

A one-click suggested change needs all of: a single literal image on its own
line, your org already holding the replacement at a matching tag, a replacement
that keeps a version, and a stage (plus anything built `FROM` it) with no `RUN`,
no shell-form `CMD`/`ENTRYPOINT`, no `ONBUILD`, and no `CMD` without an
`ENTRYPOINT`.

| Path | Upstream images | What it's demonstrating |
| --- | --- | --- |
| `apps/01-static-site` | `nginx:1.27-alpine` | The happy path. Single stage, no `RUN`, exec `ENTRYPOINT`. Should get a one-click change. |
| `apps/02-flask-api` | `python:3.12-slim` | `RUN pip install` in the only stage. Replacement named, one-click withheld. |
| `apps/03-express-api` | `node:20-alpine` | Same, for Node. |
| `apps/04-go-microservice` | `golang:1.23`, `alpine:3.20` | Split outcome in one file: builder blocked by `RUN`, runtime stage clean. |
| `apps/05-spring-boot` | `maven:3.9-eclipse-temurin-21`, `eclipse-temurin:21-jre` | Same split, Java flavor. The single most common enterprise shape. |
| `apps/06-react-frontend` | `node:20-alpine`, `nginx:1.27-alpine` | Same split, build-and-serve. |
| `apps/07-rust-service` | `rust:1.82`, `debian:bookworm-slim` | The common real blocker: the runtime stage still needs `apt-get` for CA certs. |
| `apps/08-ml-inference` | `python:${PYTHON_VERSION}-slim` | `ARG` **with** a default. Guardener substitutes it and resolves the image, but won't one-click a non-literal line. |
| `apps/09-dotnet-api` | `mcr.microsoft.com/dotnet/{sdk,aspnet}:8.0` | A registry that isn't Docker Hub. |
| `apps/10-legacy-onbuild` | `node:20-alpine` | `ONBUILD` golden-base pattern. Reported under **Not migrated**. |
| `apps/11-edge-cases` | `scratch`, digest-pinned `redis`, stage ref, bare `ARG` | Four stages, four documented skip reasons. |
| `apps/12-worker` | `python:3.12-slim` | Arrives by PR, not on `main`, so it exercises **Suggestions** rather than migration. Deps stage blocked by `RUN`, runtime stage one-click eligible. |
| `Dockerfile.dev` | `python:3.12-slim` | Excluded by `migrate.ignore.files`. Should never appear in the PR. |
| `docker-compose.yml` | postgres, redis, rabbitmq, traefik, minio | The Compose path. |
| `deploy/k8s/` | nginx, fluent-bit, postgres, aws-cli, `busybox:1.36` | Manifests, sidecars, initContainers. The busybox ref is excluded by `migrate.ignore.images`. |
| `deploy/helm/values.yaml` | fluent-bit, bitnami/redis, prometheus, grafana | A literal `image:` next to a split `registry`/`repository`/`tag` mapping. Only the literal one is one-clickable. |
| `infra/main.tf`, `scripts/deploy.sh`, `Makefile` | node, otel, flyway, terraform, kubectl, curl | The honest limit. Suggestions reports these. Migration never reads them. |

### Two deliberate negative controls

The `migrate.ignore` block earns its keep here. `Dockerfile.dev` and every
`busybox:*` reference are excluded, so when the migration PR shows up and
neither one is in it, that's the config working, not Guardener missing them.
Worth calling out live, because "it didn't touch my dev image" is a question
every platform team asks in the first five minutes.

## Demo script

**Beat 1, the backlog.** Open the PR titled *Migrate container images to
Chainguard equivalents*. It covers the whole default branch in one shot. Walk
the **Changed files** list, then walk **Not migrated** and explain the reasons,
because the refusals are more convincing than the swaps. Guardener declining to
rewrite a base out from under a `RUN` is the product being careful with someone's
build.

**Beat 2, the ratchet.** Open the PR that adds `apps/12-worker`. Suggestions
comments inline on the lines that PR adds, with one-click blocks. This is the
part that stops new upstream images from getting in after you've cleaned up.

Together: migration drains the existing debt, suggestions keeps it from coming
back.

**Beat 3, the limits.** Point at `infra/main.tf` and the `Makefile`. Migration
doesn't read them. Say so plainly and hand them `chainctl images discover` for
full-inventory coverage. Volunteering the gap buys more credibility than it
costs.

## Running the thing

The Dockerfiles are real builds, not stubs. Source is minimal but genuine.

```bash
make check                 # docker build --check over every Dockerfile
make build                 # build every app image
make up                    # bring up the Compose stack
docker build --build-arg RUNTIME_BASE=alpine:3.20 apps/11-edge-cases
```

`apps/11-edge-cases` needs that `--build-arg`. Its final stage uses an `ARG`
with no default, which is exactly the case it exists to demonstrate.

## Forcing a migration run

Migration runs on a push that touches `.chainguard/images.yaml` and then every
`migrate.period`. To trigger one on demand:

```bash
chainctl guardener github migrate create sseebald/guardener-demo
```

Needs `chainctl` **0.2.375 or later**. Earlier versions run only the Hardened
Actions migration and silently skip images. Check with `chainctl version` and
run `chainctl update` if you're behind.

## If nothing happens

1. Confirm the Chainguard App can see this repo. Installing on *selected
   repositories* won't cover one created afterwards.
2. Confirm the GitHub org is linked to your Chainguard org. Suggestions needs
   the link even on public repos.
3. Confirm the config is on the **default branch**. Guardener never reads it
   from a feature branch.
4. For a private repo, Suggestions additionally needs the org's repository
   visibility scope set to `ALL`. This repo is public, so that one doesn't bite
   here.

## Sources

Everything above is from the Guardener docs, not from memory:

- [Configuring Guardener](https://edu.chainguard.dev/chainguard/guardener/github/configuration/)
- [Container Image Suggestions](https://edu.chainguard.dev/chainguard/guardener/github/image-suggestions/)
- [Container Image Migration](https://edu.chainguard.dev/chainguard/guardener/github/image-migration/)
- [`chainctl images discover`](https://edu.chainguard.dev/chainguard/containers/migration/migration-tools/images-discover/)
