APP_NAME = isc-tar
COMMIT := $(shell git rev-parse HEAD)
IMAGE ?= daimor/$(APP_NAME):$(COMMIT)
TAGS := -t $(IMAGE) -t daimor/$(APP_NAME)
OPTIONS := -v `pwd`:/home/irisowner/$(APP_NAME) -w /home/irisowner/$(APP_NAME)

SHELL := /bin/bash

.PHONY: help build test release

help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

build: ## Build the image
	docker build $(TAGS) --no-cache .

test: build ## Run UnitTests
	docker run --rm -i $(OPTIONS) --entrypoint /tests_entrypoint.sh $(IMAGE)

release: clean build ## Export as XML
	mkdir out
	setfacl -dm 'u:51773:rw' out
	docker run --rm -i $(OPTIONS) --entrypoint /build_artifacts.sh $(IMAGE)

clean:
	-rm -rf out