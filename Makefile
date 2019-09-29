
COMPONENT_TARGETS = $(HARDWARE_BUILD)

include constants.mk

REQUIRES  = build-system/3pp/app/pkgtools/0.1.3
REQUIRES += build-system/3pp/app/genext2fs/1.4.1
REQUIRES += build-system/3pp/app/populatefs/1.1
REQUIRES += build-system/3pp/app/jsmin/0.0.1
REQUIRES += build-system/3pp/app/pseudo/1.8.2
REQUIRES += build-system/3pp/app/python2/2.7.16
REQUIRES += build-system/3pp/app/python3/3.7.4
REQUIRES += build-system/3pp/app/perl/5.30.0
REQUIRES += build-system/progs

# ======= __END_OF_REQUIRES__ =======

config_makefile = build-config.mk

BUILD_TARGETS = $(config_makefile)

CLEANUP_FILES  = $(config_makefile)
CLEANUP_FILES += $(CURDIR)/sbin
CLEANUP_FILES += $(CURDIR)/usr
CLEANUP_FILES += $(CURDIR)/var

# CORE Makefile:

include core.mk

$(config_makefile): $(config_makefile).template
	@mkdir -p $(CURDIR)/var/{tmp,pseudo}
	@echo "Creating $(config_makefile) ..."
	@cp $(config_makefile).template $@
