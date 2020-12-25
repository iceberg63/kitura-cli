RELEASE=0.2.7
BINARY_NAME=kitura
PACKAGE_NAME=kitura-cli
LINUX_DIR=linux-amd64
LINUX_PATH=/usr/local/bin
LINUX_BINARY=$(LINUX_DIR)$(LINUX_PATH)/$(BINARY_NAME)
MACOS_DIR=darwin-amd64
MACOS_PATH=/
MACOS_BINARY=$(MACOS_DIR)$(MACOS_PATH)/$(BINARY_NAME)

KITURA_SRC=$(HOME)/go/src/kitura

# Handle additional param for sed -i on Darwin
SED_FLAGS=
UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Darwin)
    SED_FLAGS := ""
endif

debug:

all: build package
build: build-linux build-darwin
package: package-linux package-darwin
clean:
	go clean
	rm -f install.sh
	rm -f $(LINUX_DIR)/DEBIAN/control
	rm -rf $(LINUX_DIR)/usr
	rm -rf $(MACOS_DIR)

setup_release:

	# Copy kitura/cmd module into GOPATH
	mkdir -p $(KITURA_SRC)
	cp -R -p cmd $(KITURA_SRC)
	# Replace release placeholders in sources
	cp install.sh.ver install.sh
	cp kitura.rb.ver kitura.rb
	cp $(LINUX_DIR)/DEBIAN/control.ver $(LINUX_DIR)/DEBIAN/control
	sed -i $(SED_FLAGS) -e"s#@@RELEASE@@#$(RELEASE)#g" install.sh $(LINUX_DIR)/DEBIAN/control $(KITURA_SRC)/cmd/root.go kitura.rb

setup_test:
	# Copy kitura/cmd module into GOPATH
	mkdir -p $(KITURA_SRC)
	cp -R -p cmd $(KITURA_SRC)

deps:
	# Install dependencies
	go get github.com/spf13/cobra/cobra
	go get gopkg.in/src-d/go-git.v4/...

## Linux
build-linux-test: setup_test deps
	GOOS=linux GOARCH=amd64 go build -o $(LINUX_BINARY) -v

build-linux-release: setup_release deps
	GOOS=linux GOARCH=amd64 go build -o $(LINUX_BINARY) -v

package-linux: build-linux-release
	cp -R -p $(LINUX_DIR) $(PACKAGE_NAME)_$(RELEASE)
	chmod -R 755 $(LINUX_DIR)$(LINUX_PATH)
	dpkg-deb --build $(PACKAGE_NAME)_$(RELEASE)
	mv $(PACKAGE_NAME)_$(RELEASE).deb kitura-cli_test_amd64.deb
	tar -czf $(PACKAGE_NAME)_$(RELEASE)_linux.tar.gz $(LINUX_DIR)/usr/
	rm -r $(PACKAGE_NAME)_$(RELEASE)

## MacOS
build-darwin: setup deps
	GOOS=darwin GOARCH=amd64 go build -o $(MACOS_BINARY) -v

package-darwin-tar: build-darwin
	tar -czf $(PACKAGE_NAME)_$(RELEASE)_darwin.tar.gz $(MACOS_DIR)

package-darwin: package-darwin-tar
	# This syntax defines SHA_VALUE at rule execution time.
	# Note: separate rule to delay evaluation until tar.gz has been written
	$(eval SHA_VALUE := $(shell shasum -a 256 $(PACKAGE_NAME)_$(RELEASE)_darwin.tar.gz | cut -d' ' -f1))
	sed -i $(SED_FLAGS) -e"s#@@SHA256@@#$(SHA_VALUE)#" kitura.rb
