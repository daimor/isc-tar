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

build: ## Build the image with tests
	docker build $(TAGS) --build-arg TESTS=1 .

release: clean build ## Export as XML
	docker run --rm -i $(OPTIONS) -v `pwd`/.ci/build_artifacts.sh:/build_artifacts.sh -v `pwd`/out/:/home/irisowner/isc-tar/out/ -w /home/irisowner/isc-tar/ --entrypoint /build_artifacts.sh $(IMAGE)

clean:
	-rm -rf out