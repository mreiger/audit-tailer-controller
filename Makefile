.ONESHELL:
SHA := $(shell git rev-parse --short=8 HEAD)
GITVERSION := $(shell git describe --long --all)
BUILDDATE := $(shell date -Iseconds)
VERSION := $(or ${VERSION},devel)

BINARY := audit-forwarder

.PHONY: test
test:
	# go test -v -cover ./...

.PHONY: all
bin/$(BINARY): test
	GGO_ENABLED=0 \
	GO111MODULE=on \
		go build \
			-trimpath \
			-tags netgo \
			-o bin/$(BINARY) \
			-ldflags "-X 'github.com/metal-stack/v.Version=$(VERSION)' \
					-X 'github.com/metal-stack/v.Revision=$(GITVERSION)' \
					-X 'github.com/metal-stack/v.GitSHA1=$(SHA)' \
					-X 'github.com/metal-stack/v.BuildDate=$(BUILDDATE)'" . && strip bin/$(BINARY)
	strip bin/$(BINARY)

.PHONY: release
release: bin/$(BINARY)
	rm -rf rel
	mkdir -p rel/usr/local/bin
	cp bin/$(BINARY) rel/usr/local/bin
	cd rel \
	&& tar -cvzf $(BINARY).tgz usr/local/bin/$(BINARY) \
	&& mv $(BINARY).tgz .. \
	&& cd -

dockerimage:
	docker build -t mreiger/audit-forwarder .

.PHONY: all
all:: release;
