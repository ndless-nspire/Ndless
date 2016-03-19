SUBDIRS = libsyscalls libndls thirdparty tools samples system

all: $(patsubst %, build-%, $(SUBDIRS))
clean: $(patsubst %, clean-%, $(SUBDIRS))

build-libndls: build-libsyscalls
build-tools: build-thirdparty
build-samples: build-libndls build-tools build-thirdparty build-system

.PHONY: all clean

build-%: %
	+$(MAKE) -C $<

clean-%: %
	+$(MAKE) -C $< clean

docker: docker-arm-gcc docker-ndless-sdk

docker-arm-gcc:Dockerfile.arm-gcc
	@# works around https://github.com/docker/docker/issues/2112
	cp Dockerfile.arm-gcc Dockerfile
	sudo docker build -t ndless/arm-gcc .
	rm Dockerfile

docker-ndless-sdk: Dockerfile.ndless-sdk
	@# works around https://github.com/docker/docker/issues/2112
	cp Dockerfile.ndless-sdk Dockerfile
	sudo docker build -t ndless/ndless-sdk .
	rm Dockerfile

