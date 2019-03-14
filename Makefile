APP_NAME = tar
IMAGE = intersystems/$(APP_NAME)

.PHONY: help build test

help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

build: ## Build the container
	docker build -t $(IMAGE) .

test: build ## Run UnitTests
	$(eval TEMPDIR := $(shell mktemp -d /tmp/$(APP_NAME).XXXXXX))
	echo \
		"set ^UnitTestRoot=\"/opt/tests/cls\"\n" \
		"do ##class(%UnitTest.Manager).RunTestSuites()\n" \
		"halt" > $(TEMPDIR)/tests.scr
	echo "#!/bin/bash\n\ncat /opt/extra/tests.scr\n" \
		"iris start \$$ISC_PACKAGE_INSTANCENAME quietly\n" \
		"iris session \$$ISC_PACKAGE_INSTANCENAME -U%SYS < /opt/extra/tests.scr\n" \
		"iris stop \$$ISC_PACKAGE_INSTANCENAME quietly\n" > $(TEMPDIR)/tests.sh
	chmod a+x $(TEMPDIR)/tests.sh
	docker run --rm -i \
		-v $(HOME)/iris.key:/usr/irissys/mgr/iris.key \
		-v $(shell pwd)/tests:/opt/tests \
		-v $(TEMPDIR)/tests.sh:/opt/extra/tests.sh \
		-v $(TEMPDIR)/tests.scr:/opt/extra/tests.scr \
		--entrypoint /opt/extra/tests.sh \
		$(IMAGE)
	rm -rf $(TEMPDIR)