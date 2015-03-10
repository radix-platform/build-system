
COMPONENT_TARGETS = $(HARDWARE_BUILD)

include ../../build-system/constants.mk

# ======= __END_OF_REQUIRES__ =======

config_target = .config

BUILD_TARGETS = $(config_target)

CLEANUP_FILES += autom4te.cache
CLEANUP_FILES += $(config_target)
CLEANUP_FILES += config.log
CLEANUP_FILES += config.status
CLEANUP_FILES += configure

include ../../build-system/core.mk

$(config_target):
	@autoconf
	@rm -rf autom4te.cache
	@./configure
