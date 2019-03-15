APP_NAME = tar
IMAGE = intersystems/$(APP_NAME)

.PHONY: help build test

help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

build: ## Build the container
	docker build --no-cache -t $(IMAGE) .

test: build ## Run UnitTests
	docker build --no-cache -t $(IMAGE)-test -f Dockerfile.test .
	docker run --rm -i $(IMAGE)-test
