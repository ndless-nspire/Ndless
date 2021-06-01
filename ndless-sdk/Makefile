SUBDIRS = libsyscalls libndls thirdparty tools samples system

all: $(patsubst %, build-%, $(SUBDIRS))
clean: $(patsubst %, clean-%, $(SUBDIRS))

build-libndls: build-libsyscalls
build-tools: build-thirdparty
build-samples: build-libndls build-tools build-thirdparty build-system
build-thirdparty: build-libsyscalls

.PHONY: all clean

build-%: %
	+$(MAKE) -C $<

clean-%: %
	+$(MAKE) -C $< clean

docker: Dockerfile.ndless

docker-ndless: Dockerfile.ndless
	docker build . -t ndless/ndless

