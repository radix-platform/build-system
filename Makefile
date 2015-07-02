
COMPONENT_TARGETS = $(HARDWARE_BUILD)

include constants.mk

REQUIRES  = build-system/3pp/fakeroot/0.18
REQUIRES += build-system/3pp/dialog/1.2-20140112
REQUIRES += build-system/progs


# ======= __END_OF_REQUIRES__ =======


config_makefile = build-config.mk

BUILD_TARGETS = $(config_makefile)

CLEANUP_FILES  = $(config_makefile)
CLEANUP_FILES += $(CURDIR)/sbin

CLEANUP_FILES += $(CURDIR)/pkgtool/check-db-integrity
CLEANUP_FILES += $(CURDIR)/pkgtool/check-package
CLEANUP_FILES += $(CURDIR)/pkgtool/check-requires
CLEANUP_FILES += $(CURDIR)/pkgtool/install-package
CLEANUP_FILES += $(CURDIR)/pkgtool/make-package
CLEANUP_FILES += $(CURDIR)/pkgtool/remove-package
CLEANUP_FILES += $(CURDIR)/pkgtool/update-package


# CORE Makefile:

include core.mk


$(config_makefile): $(config_makefile).template
	@( cd $(CURDIR)/pkgtool ; \
	   cat check-db-integrity.in | sed -e "s/@DISTRO@/$(DISTRO_NAME)/g" > check-db-integrity ; \
	   cat check-package.in      | sed -e "s/@DISTRO@/$(DISTRO_NAME)/g" > check-package      ; \
	   cat check-requires.in     | sed -e "s/@DISTRO@/$(DISTRO_NAME)/g" > check-requires     ; \
	   cat install-package.in    | sed -e "s/@DISTRO@/$(DISTRO_NAME)/g" > install-package    ; \
	   cat make-package.in       | sed -e "s/@MKPKGVERSION@/$(SYSTEM_VERSION)/g" \
	                             | sed -e "s,@BUGURL@,$(BUG_URL),g"     > make-package       ; \
	   cat remove-package.in     | sed -e "s/@DISTRO@/$(DISTRO_NAME)/g" > remove-package     ; \
	   cat update-package.in     | sed -e "s/@DISTRO@/$(DISTRO_NAME)/g" > update-package     ; \
	   chmod 0755 check-db-integrity ; \
	   chmod 0755 check-package      ; \
	   chmod 0755 check-requires     ; \
	   chmod 0755 install-package    ; \
	   chmod 0755 make-package       ; \
	   chmod 0755 remove-package     ; \
	   chmod 0755 update-package     ; \
	 )
	@echo "Creating $(config_makefile) ..."
	@cp $(config_makefile).template $@
