
COMPONENT_TARGETS = $(HARDWARE_BUILD)

include constants.mk

REQUIRES  = build-system/3pp/fakeroot/0.18
REQUIRES += build-system/progs


config_makefile = build-config.mk

BUILD_TARGETS = $(config_makefile)

CLEANUP_FILES  = $(config_makefile)
CLEANUP_FILES += $(CURDIR)/sbin

CLEANUP_FILES += $(CURDIR)/pkgtool/check-db-integrity
CLEANUP_FILES += $(CURDIR)/pkgtool/check-package
CLEANUP_FILES += $(CURDIR)/pkgtool/check-requires
CLEANUP_FILES += $(CURDIR)/pkgtool/install-package
CLEANUP_FILES += $(CURDIR)/pkgtool/remove-package
CLEANUP_FILES += $(CURDIR)/pkgtool/upgrade-package


# CORE Makefile:

include core.mk


$(config_makefile): $(config_makefile).template
	@( cd $(CURDIR)/pkgtool ; \
	   cat check-db-integrity.in | sed -e "s/@DISTRO@/$(DISTRO_NAME)/g" > check-db-integrity ; \
	   cat check-package.in      | sed -e "s/@DISTRO@/$(DISTRO_NAME)/g" > check-package      ; \
	   cat check-requires.in     | sed -e "s/@DISTRO@/$(DISTRO_NAME)/g" > check-requires     ; \
	   cat install-package.in    | sed -e "s/@DISTRO@/$(DISTRO_NAME)/g" > install-package    ; \
	   cat remove-package.in     | sed -e "s/@DISTRO@/$(DISTRO_NAME)/g" > remove-package     ; \
	   cat upgrade-package.in    | sed -e "s/@DISTRO@/$(DISTRO_NAME)/g" > upgrade-package    ; \
	   chmod 0755 check-db-integrity ; \
	   chmod 0755 check-package      ; \
	   chmod 0755 check-requires     ; \
	   chmod 0755 install-package    ; \
	   chmod 0755 remove-package     ; \
	   chmod 0755 upgrade-package    ; \
	 )
	@echo "Creating $(config_makefile) ..."
	@cp $(config_makefile).template $@
