
COMPONENT_TARGETS = $(HARDWARE_BUILD)

include ../../../../build-system/constants.mk

SOURCE_REQUIRES = build-system/3pp/sources/packages/fakeroot


# ======= __END_OF_REQUIRES__ =======

version         = 1.20.2
tar_xz_archive  = $(BUILDSYSTEM)/3pp/sources/packages/fakeroot/fakeroot-$(version).tar.xz
SRC_ARCHIVE     = $(tar_xz_archive)
SRC_DIR         = $(TARGET_BUILD_DIR)/fakeroot-$(version)

src_done        = $(TARGET_BUILD_DIR)/.source-done
src_dir_name    = fakeroot-$(version)
build_dir       = $(TARGET_BUILD_DIR)/built

PATCHES = PATCHES

build_target    = $(TARGET_BUILD_DIR)/.built
install_target  = $(TARGET_BUILD_DIR)/.installed

script          = $(CURDIR)/scripts/fakeroot

environment     =
extra_configure_switches  = --disable-dependency-tracking
extra_configure_switches += --mandir=/usr/share/man
extra_configure_switches += --libdir=/usr/lib
extra_configure_switches += --program-prefix=_
extra_configure_switches += --program-suffix=-sysv


BUILD_TARGETS = $(install_target)

include ../../../../build-system/core.mk

$(src_done): $(SRC_ARCHIVE) $(PATCHES_DEP)
	$(UNPACK_SRC_ARCHIVE)
	$(APPLY_PATCHES)
	@touch $@

$(build_target): $(src_done)
	@mkdir -p $(build_dir)
	@cd $(build_dir) && $(environment) ../$(src_dir_name)/configure \
	  --prefix=/usr \
	  $(extra_configure_switches)
	@$(environment) $(MAKE) -C $(build_dir)
	@touch $@

$(install_target): $(build_target)
	@echo -e "\n======= Installing FAKEROOT binary =======\n"
	@cd $(build_dir) && $(MAKE) install DESTDIR=$(BUILDSYSTEM)
	@echo -e "\n======= Installing FAKEROOT wrapper =======\n"
	@mkdir -p $(BUILDSYSTEM)/sbin && \
	  cp -a $(script) $(BUILDSYSTEM)/sbin/fakeroot && \
	  chmod a+x $(BUILDSYSTEM)/sbin/fakeroot       && \
	  echo "FAKEROOT := $(BUILDSYSTEM)/sbin/fakeroot" >> $(BUILDSYSTEM)/sbin/.config
	@touch $@
