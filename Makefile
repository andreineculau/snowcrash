-include config.mk

BUILDTYPE ?= Release
BUILD_DIR ?= ./build
PYTHON ?= python
GYP ?= ./tools/gyp/gyp

# Default to verbose builds
V ?= 1

# Targets
.PHONY: all
all: libsnowcrash test-libsnowcrash snowcrash

.PHONY: libsnowcrash
libsnowcrash: config.gypi $(BUILD_DIR)/Makefile
	$(MAKE) -C $(BUILD_DIR) V=$(V) libsnowcrash

.PHONY: test-libsnowcrash
test-libsnowcrash: config.gypi $(BUILD_DIR)/Makefile
	$(MAKE) -C $(BUILD_DIR) V=$(V) test-libsnowcrash
	mkdir -p ./bin
	cp -f $(BUILD_DIR)/out/$(BUILDTYPE)/test-libsnowcrash ./bin/test-libsnowcrash

.PHONY: perf-libsnowcrash
perf-libsnowcrash: config.gypi $(BUILD_DIR)/Makefile
	$(MAKE) -C $(BUILD_DIR) V=$(V) perf-libsnowcrash
	mkdir -p ./bin
	cp -f $(BUILD_DIR)/out/$(BUILDTYPE)/perf-libsnowcrash ./bin/perf-libsnowcrash

.PHONY: snowcrash
snowcrash: config.gypi $(BUILD_DIR)/Makefile
	$(MAKE) -C $(BUILD_DIR) V=$(V) snowcrash
	mkdir -p ./bin
	cp -f $(BUILD_DIR)/out/$(BUILDTYPE)/snowcrash ./bin/snowcrash

config.gypi: configure
	$(PYTHON) ./configure

$(BUILD_DIR)/Makefile:
	$(GYP) -f make --generator-output $(BUILD_DIR) --depth=.

.PHONY: clean
clean:
	rm -rf $(BUILD_DIR)/out
	rm -rf ./bin

.PHONY: distclean
distclean:
	rm -rf ./build
	rm -f ./config.mk
	rm -f ./config.gypi
	rm -rf ./bin	

.PHONY: test
test: test-libsnowcrash snowcrash
	$(BUILD_DIR)/out/$(BUILDTYPE)/test-libsnowcrash

ifdef INTEGRATION_TESTS
	bundle exec cucumber
endif	

.PHONY: perf
perf: perf-libsnowcrash
	$(BUILD_DIR)/out/$(BUILDTYPE)/perf-libsnowcrash ./test/performance/fixtures/fixture-1.md

.PHONY: install
install: snowcrash
	cp -f $(BUILD_DIR)/out/$(BUILDTYPE)/snowcrash /usr/local/bin/snowcrash
