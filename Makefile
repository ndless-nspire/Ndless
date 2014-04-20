SUBDIRS = libndls Ndless-SDK tools arm
SUBDIR_TOOLS = tools
DISTDIRS = calcbin

all: subdirs

.PHONY: subdirs

subdirs:
	@for i in $(SUBDIRS); do \
	echo "make all in $$i..."; \
  (cd $$i; make all) || exit 1; done

all_tools:
	@for i in $(SUBDIR_TOOLS); do \
	echo "make all in $$i..."; \
  (cd $$i; make all) || exit 1; done

distdir:
	mkdir -p dist	

distsamples: distdir samples
	mkdir -p dist/samples
	cp Ndless-SDK/_samples/link-sdl/Link.tns dist/samples

# Incremental binary dist for development
distbin: distdir all distsamples
	@# system's artefacts shouldn't be distributed
	(cd Ndless-SDK/ndless/system && make clean)
	cp -r $(DISTDIRS) dist
	cp "Mozilla-Public-License-v1.1.html" doc/ReadMe.txt dist
	find dist -name .svn -o -name "*~" | xargs rm -rf

# Dist with cleanup, binary and source
dist: cleandist distsrc distbin
	find dist -name .svn | xargs rm -rf

distsrc: clean
	mkdir -p dist/src
	-cp -r `ls | grep -v dist | grep -v Ndless-SDK` dist/src
	find dist -name Makefile.config -o -name upload_cookies.txt | xargs rm -rf

distsdk: cleandistsdk
	mkdir -p distsdk
	cp -r Ndless-SDK/* distsdk
	find distsdk -name .svn -o -name "*~" -o -name "*.img.tns" -o -name "*.img" -o -name "*.tcc" -o -name "yagarto" -o -name "mingw-get" | xargs rm -rf

distmsys: cleandistmsys
	mkdir -p distsdk-msys-yagarto
	cp -r Ndless-SDK/yagarto distsdk-msys-yagarto
	cp -r Ndless-SDK/mingw-get distsdk-msys-yagarto
	cp doc/ReadMe-MSYS-YAGARTO.txt distsdk-msys-yagarto

cleandist:
	rm -rf dist

cleandistmsys:
	rm -rf distsdk-msys-yagarto

cleandistsdk:
	rm -rf distsdk

clean: cleandist cleandistsdk cleandistmsys
	@for i in $(SUBDIRS); do \
	echo "Clearing in $$i..."; \
	(cd $$i; make clean) || exit 1; done
	(cd Ndless-SDK/ndless/system && make clean)
	@# may fail because of nspire_emu keeping a lock on it
	-rm -rf calcbin

# Useful shortcuts
.PHONY: libndls
libndls:
	(cd libndls && make)
rlibndls:
	(cd libndls && make clean all)

.PHONY: samples
samples:
	(cd Ndless-SDK/_samples && make)
rsamples:
	(cd Ndless-SDK/_samples && make clean all)

.PHONY: tests
tests:
	(cd arm/tests && make)
rtests:
	(cd arm/tests && make clean all)

_upload_msys:
	rev=`git rev-list HEAD | wc -l`; \
	hash=`git rev-parse --short HEAD`; \
	mv distsdk-msys-yagarto "ndless-v3.6-beta-r$$rev.$$hash-sdk-msys-yagarto"; \
	rm -rf ndless-sdk-msys-yagarto.zip ; \
	7z -r ndless-sdk-msys-yagarto.zip "ndless-v3.6-beta-r$$rev.$$hash-sdk-msys-yagarto"; \
	rm -rf ndless-sdk-msys-yagarto.zip ; \-sdk-msys-yagarto" > /dev/null; \
	curl --cookie upload_cookies.txt -F 'super_id=7' -F 'form_type=file' -F '__FORM_TOKEN=ffa21de629e1d6de857923e4' -F "name=ndless-v3.6-beta-r$$rev.$$hash-sdk-msys-yagarto"; \
	rm -rf ndless-sdk-msys-yagarto.zip ; \-msys-yagarto.zip" -F 'submit=Submit' -F 'file_to_upload=@ndless-msys-yagarto.zip' -F 'sort=' -F 'architecture=' -F 'notes=' http://www.unsads.com/projects/nsptools/admin/general/downloader/files/release/7 > /dev/null; \
	rm -rf ndless-sdk-msys-yagarto.zip ; \
	rm -rf "ndless-v3.6-beta-r$$rev.$$hash-sdk-msys-yagarto"; \
	rm -rf ndless-sdk-msys-yagarto.zip ; \-sdk-msys-yagarto"; \
	echo "MSYS/YAGARTO addin 3.6 r$$rev.$$hash available at http://www.unsads.com/projects/nsptools/downloader/download/release/7"

_upload_sdk:
	rev=`git rev-list HEAD | wc -l`; \
	hash=`git rev-parse --short HEAD`; \
	mv distsdk "ndless-v3.6-beta-r$$rev.$$hash-sdk"; \
	rm -rf ndless-sdk.zip ; \
	7z -r ndless-sdk.zip "ndless-v3.6-beta-r$$rev.$$hash-sdk" > /dev/null; \
	curl --cookie upload_cookies.txt -F 'super_id=5' -F 'form_type=file' -F '__FORM_TOKEN=ffa21de629e1d6de857923e4' -F "name=ndless-v3.6-beta-r$$rev.$$hash-sdk.zip" -F 'submit=Submit' -F 'file_to_upload=@ndless-sdk.zip' -F 'sort=' -F 'architecture=' -F 'notes=' http://www.unsads.com/projects/nsptools/admin/general/downloader/files/release/5 > /dev/null; \
	rm -rf ndless-sdk.zip; \
	rm -rf "ndless-v3.6-beta-r$$rev.$$hash-sdk"; \
	echo "SDK 3.6 r$$rev.$$hash available at http://www.unsads.com/projects/nsptools/downloader/download/release/5"

_upload_ndless:
	rev=`git rev-list HEAD | wc -l`; \
	hash=`git rev-parse --short HEAD`; \
	mv dist "ndless-v3.6-beta-r$$rev-$$hash"; \
	rm -rf ndless.zip ; \
	7z -r ndless.zip "ndless-v3.6-beta-r$$rev-$$hash" > /dev/null; \
	curl --cookie upload_cookies.txt -F 'super_id=1' -F 'form_type=file' -F '__FORM_TOKEN=ffa21de629e1d6de857923e4' -F "name=ndless-v3.6-beta-r$$rev-$$hash.zip" -F 'submit=Submit' -F 'file_to_upload=@ndless.zip' -F 'sort=' -F 'architecture=' -F 'notes=' http://www.unsads.com/projects/nsptools/admin/general/downloader/files/release/1 > /dev/null; \
	rm -rf ndless.zip; \
	rm -rf "ndless-v3.6-beta-r$$rev-$$hash"; \
	echo "Ndless 3.6 r$$rev-$$hash available at http://www.unsads.com/projects/nsptools/downloader/download/release/1"

upload_msys: update_version_info distmsys _upload_msys revert_version_info
upload_sdk: update_version_info distsdk _upload_sdk revert_version_info
upload_ndless: update_version_info dist _upload_ndless revert_version_info

upload: update_version_info dist distsdk distmsys _upload_msys _upload_sdk _upload_ndless
upload_sdk_ndless: dist distsdk _upload_sdk _upload_ndless

# Increment only if the last update was not an increment
update_version_info:
	rev=`git rev-list HEAD | wc -l`; \
	echo "#define NDLESS_REVISION $$rev" > arm/ndless_version.h; \
	echo "ndless_revision=\"$$rev\"" > arm/ndless_version.lua;

revert_version_info:
	git reset --hard

