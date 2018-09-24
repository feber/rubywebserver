.PHONY: all test dep build push checkenv deploy kubefile setup migrate

IMAGE = registry.bukalapak.io/bukalapak/rubywebserver/$(svc)
DIRS  = $(shell cd deploy && ls -d */ | grep -v "_output")
FILE ?= deployment
ODIR := deploy/_output

export VERSION            ?= $(shell git show -q --format=%h)
export VAR_SERVICES       ?= $(DIRS:/=)
export VAR_KUBE_NAMESPACE ?= default
export VAR_CONSUL_PREFIX  ?= rubywebserver

all: build push deploy

test:
	rake test

dep:
	bundle install

$(ODIR):
	@mkdir -p $(ODIR)

build:
	@$(foreach svc, $(VAR_SERVICES), \
		docker build -t $(IMAGE):$(VERSION) -f ./deploy/$(svc)/Dockerfile .;)

push:
	@$(foreach svc, $(VAR_SERVICES), \
		docker push $(IMAGE):$(VERSION);)

checkenv:
ifndef ENV
	$(error ENV must be set.)
endif

deploy: checkenv $(ODIR)
	@$(foreach svc, $(VAR_SERVICES), \
		echo deploying "$(svc)" to environment "$(ENV)" && \
		! kubelize genfile --overwrite -c ./ -s $(svc) -e $(ENV) deploy/$(svc)/$(FILE).yml $(ODIR)/$(svc)/ || \
		kubectl replace -f $(ODIR)/$(svc)/$(FILE).yml || kubectl create -f $(ODIR)/$(svc)/$(FILE).yml ;)

# only generate files from services
kubefile: checkenv $(ODIR)
	$(foreach svc, $(VAR_SERVICES), \
		$(foreach f, $(shell ls deploy/$(svc)/*.yml), \
			kubelize genfile --overwrite -c ./ -s $(svc) -e $(ENV) $(f) $(ODIR)/$(svc)/;))

setup:
	docker run --rm -it --network host -v $PWD/db:/app/db -v $PWD/.env:/app/.env registry.bukalapak.io/sre/migration:0.0.1 db:create
	docker run --rm -it --network host -v $PWD/db:/app/db -v $PWD/.env:/app/.env registry.bukalapak.io/sre/migration:0.0.1 db:migrate

migrate:
	docker run --rm -it --network host -v $PWD/db:/app/db -v $PWD/.env:/app/.env registry.bukalapak.io/sre/migration:0.0.1 db:migrate
