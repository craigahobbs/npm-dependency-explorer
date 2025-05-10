# Licensed under the MIT License
# https://github.com/craigahobbs/npm-dependency-explorer/blob/main/LICENSE


# Download python-build
PYTHON_BUILD_DIR ?= ../python-build
define WGET
ifeq '$$(wildcard $(notdir $(1)))' ''
$$(info Downloading $(notdir $(1)))
$$(shell [ -f $(PYTHON_BUILD_DIR)/$(notdir $(1)) ] && cp $(PYTHON_BUILD_DIR)/$(notdir $(1)) . || $(call WGET_CMD, $(1)))
endif
endef
WGET_CMD = if command -v wget >/dev/null 2>&1; then wget -q -c $(1); else curl -f -Os $(1); fi
$(eval $(call WGET, https://craigahobbs.github.io/python-build/Makefile.tool))


# Include python-build
include Makefile.tool


# Development dependencies
TESTS_REQUIRE := bare-script


clean:
	rm -rf Makefile.tool


test: $(DEFAULT_VENV_BUILD)
	$(DEFAULT_VENV_BIN)/bare -m test/runTests.bare$(if $(DEBUG), -d)$(if $(TEST), -v vTest "'$(TEST)'")


lint: $(DEFAULT_VENV_BUILD)
	$(DEFAULT_VENV_BIN)/bare -s *.bare test/*.bare
