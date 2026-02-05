IMAGE_NAME ?= mheers/opencode-sandbox
TAG ?= latest

.PHONY: build
build:
	docker build -t $(IMAGE_NAME):$(TAG) .

.PHONY: publish
publish:
	docker push $(IMAGE_NAME):$(TAG)
