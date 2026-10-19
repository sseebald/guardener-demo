# DEMO FIXTURE. Upstream images on purpose. See README.md.
#
# Makefiles are reported by Image Suggestions but never read by migration.

APPS := 01-static-site 02-flask-api 03-express-api 04-go-microservice \
        05-spring-boot 06-react-frontend 07-rust-service 08-ml-inference \
        09-dotnet-api 10-legacy-onbuild

REGISTRY ?= ghcr.io/sseebald/guardener-demo
TAG      ?= dev

.PHONY: help
help:
	@echo "Targets:"
	@echo "  build        Build every demo image"
	@echo "  check        Run 'docker build --check' over every Dockerfile"
	@echo "  lint         Lint Go, shell and YAML via containers"
	@echo "  up           Bring up the Compose stack"
	@echo "  down         Tear down the Compose stack"

.PHONY: build
build:
	@for app in $(APPS); do \
		echo "==> building $$app"; \
		docker build -t $(REGISTRY)/$$app:$(TAG) apps/$$app || exit 1; \
	done

.PHONY: check
check:
	@for df in $$(find . -name 'Dockerfile' -o -name 'Dockerfile.*'); do \
		echo "==> checking $$df"; \
		docker build --check -f $$df $$(dirname $$df) || exit 1; \
	done

.PHONY: lint
lint:
	docker run --rm -v $(PWD)/apps/04-go-microservice:/app -w /app \
		golangci/golangci-lint:v1.61-alpine golangci-lint run ./...
	docker run --rm -v $(PWD):/mnt -w /mnt \
		koalaman/shellcheck:v0.10.0 scripts/deploy.sh
	docker run --rm -v $(PWD):/data \
		cytopia/yamllint:latest -d relaxed deploy/

.PHONY: up
up:
	docker compose up --build -d

.PHONY: down
down:
	docker compose down -v
