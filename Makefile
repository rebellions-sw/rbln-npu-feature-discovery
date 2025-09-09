# === Docker image related variables ===
IMAGE_NAME             := rebellions/rbln-npu-feature-discovery
IMAGE_TAG              := $(VERSION)
DOCKER_PLATFORM        := linux/amd64
VERSION                ?= latest

# === Default settings ===
.DEFAULT_GOAL := help

.PHONY: help build-image build-push

help:
	@echo "Available Makefile targets for RBLN NPU feature discovery image:"
	@echo "  build-image   - Build and load Docker image locally (VERSION required)"
	@echo "  build-push    - Build Docker image and push to Harbor (VERSION required)"
	@echo ""
	@echo "Usage examples:"
	@echo "  make build-image VERSION=v1.0.0"
	@echo "  make build-push VERSION=v1.0.0"

build-image:
	@if [ "$(VERSION)" = "latest" ]; then \
		echo "Error: Please specify VERSION explicitly. Example: make build-image VERSION=v1.0.0"; \
		exit 1; \
	fi
	@echo "Building $(IMAGE_NAME):$(IMAGE_TAG) image using Docker BuildKit..."
	@docker buildx build \
		--platform $(DOCKER_PLATFORM) \
		--build-arg VERSION=$(VERSION) \
		--tag $(IMAGE_NAME):$(IMAGE_TAG) \
		--load \
		.
	@echo "Image build completed: $(IMAGE_NAME):$(IMAGE_TAG)"

build-push:
	@if [ "$(VERSION)" = "latest" ]; then \
		echo "Error: Please specify VERSION explicitly. Example: make build-push VERSION=v1.0.0"; \
		exit 1; \
	fi
	@echo "Building and pushing Docker image to Harbor with multi-platform support..."
	@docker buildx build \
		--platform $(DOCKER_PLATFORM) \
		--build-arg VERSION=$(VERSION) \
		--tag $(IMAGE_NAME):$(IMAGE_TAG) \
		--push \
		.
	@echo "Image push completed: $(IMAGE_NAME):$(IMAGE_TAG)"
