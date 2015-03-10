
COMPONENT_TARGETS = $(HARDWARE_BUILD)

include ../../../constants.mk

SOURCE_REQUIRES = build-system/3pp/sources/packages/fakeroot-ng


# ======= __END_OF_REQUIRES__ =======


tar_bz2_archive = $(BUILDSYSTEM)/3pp/sources/packages/fakeroot-ng/fakeroot-ng-0.18.tar.bz2
src_dir         = fakeroot-ng-0.18
build_dir       = $(TARGET_BUILD_DIR)/built

src_done        = $(TARGET_BUILD_DIR)/.source-done
SRC_DIR         = $(TARGET_BUILD_DIR)/fakeroot-ng-0.18
SRC_ARCHIVE     = $(tar_bz2_archive)

build_target    = $(TARGET_BUILD_DIR)/.built
install_target  = $(TARGET_BUILD_DIR)/.installed

environment     =
extra_configure_switches = --with-memdir=/dev/shm

BUILD_TARGETS = $(install_target)

include ../../../../build-system/core.mk

$(src_done): $(SRC_ARCHIVE) $(PATCHES_DEP)
	$(UNPACK_SRC_ARCHIVE)
	@touch $@

$(build_target): $(src_done)
	@mkdir -p $(build_dir)
	@cd $(build_dir) && $(environment) ../$(src_dir)/configure \
	  --prefix=/usr \
	  $(extra_configure_switches)
	@$(environment) $(MAKE) -C $(build_dir) all
	@cd $(build_dir) && mv fakeroot-ng fakeroot
	@touch $@

$(install_target): $(build_target)
	@echo -e "\n======= Installing FAKEROOT binary =======\n"
	@mkdir -p $(BUILDSYSTEM)/sbin && \
	  cp -a $(build_dir)/fakeroot $(BUILDSYSTEM)/sbin && \
	  echo "FAKEROOT := $(BUILDSYSTEM)/sbin/fakeroot" >> $(BUILDSYSTEM)/sbin/.config
	@touch $@
