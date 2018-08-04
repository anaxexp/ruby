-include env_make

RUBY_VER ?= 2.5.1
RUBY_VER_MINOR ?= $(shell echo "${RUBY_VER}" | grep -oE '^[0-9]+\.[0-9]+')

REPO = anaxexp/ruby
NAME = ruby-$(RUBY_VER_MINOR)

ANAXEXP_USER_ID ?= 1000
ANAXEXP_GROUP_ID ?= 1000

BASE_IMAGE_TAG = $(RUBY_VER)

ifeq ($(TAG),)
    ifneq ($(RUBY_DEV),)
    	TAG ?= $(RUBY_VER_MINOR)-dev
    else
        TAG ?= $(RUBY_VER_MINOR)
    endif
endif

ifneq ($(RUBY_DEV),)
    NAME := $(NAME)-dev
endif

ifneq ($(STABILITY_TAG),)
    ifneq ($(TAG),latest)
        override TAG := $(TAG)-$(STABILITY_TAG)
    endif
endif

.PHONY: build test push shell run start stop logs clean release

default: build

build:
	docker build -t $(REPO):$(TAG) \
		--build-arg BASE_IMAGE_TAG=$(BASE_IMAGE_TAG) \
		--build-arg RUBY_DEV=$(RUBY_DEV) \
		--build-arg ANAXEXP_USER_ID=$(ANAXEXP_USER_ID) \
		--build-arg ANAXEXP_GROUP_ID=$(ANAXEXP_GROUP_ID) \
		./

test:
	echo ok
#	cd ./test && IMAGE=$(REPO):$(TAG) ./run.sh

push:
	docker push $(REPO):$(TAG)

shell:
	docker run --rm --name $(NAME) -i -t $(PORTS) $(VOLUMES) $(ENV) $(REPO):$(TAG) /bin/bash

run:
	docker run --rm --name $(NAME) $(PORTS) $(VOLUMES) $(ENV) $(REPO):$(TAG) $(CMD)

start:
	docker run -d --name $(NAME) $(PORTS) $(VOLUMES) $(ENV) $(REPO):$(TAG)

stop:
	docker stop $(NAME)

logs:
	docker logs $(NAME)

clean:
	-docker rm -f $(NAME)

release: build push
