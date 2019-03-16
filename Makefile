APP_NAME = isc-tar
IMAGE ?= daimor/$(APP_NAME)

SHELL := /bin/bash

.PHONY: help build test release

help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

build: ## Build the image
	docker build -t $(IMAGE) .

test: build ## Run UnitTests
	docker run --rm -i -v `pwd`/tests:/opt/tests -w /opt --entrypoint /tests_entrypoint.sh $(IMAGE)

release: clean build ## Export as XML
	docker run --rm -i -v `pwd`/out:/opt/out -w /opt --entrypoint /build_artifacts.sh $(IMAGE)

clean:
	-rm -rf out