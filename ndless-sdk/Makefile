SUBDIRS = tools libsyscalls libndls samples

all:
	@for i in $(SUBDIRS); do \
	echo "make all in $$i..."; \
	(cd $$i; make all) || exit 1; done
  
clean:
	@for i in $(SUBDIRS); do \
	echo "Clearing in $$i..."; \
	(cd $$i; make clean) || exit 1; done

docker: Dockerfile.arm-gcc Dockerfile.ndless-sdk
	@# works around https://github.com/docker/docker/issues/2112
	cp Dockerfile.arm-gcc Dockerfile
	sudo docker build -t ndless/arm-gcc .
	cp Dockerfile.ndless-sdk Dockerfile
	sudo docker build -t ndless/ndless-sdk .
	rm Dockerfile

