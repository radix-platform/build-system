
COMPONENT_TARGETS = $(HARDWARE_BUILD)

include ../../../../build-system/constants.mk

SOURCE_REQUIRES = build-system/3pp/sources/packages/dialog


# ======= __END_OF_REQUIRES__ =======


tar_gz_archive  = $(BUILDSYSTEM)/3pp/sources/packages/dialog/dialog-1.2-20140112.tgz
src_dir         = dialog-1.2-20140112
build_dir       = $(TARGET_BUILD_DIR)/built

src_done        = $(TARGET_BUILD_DIR)/.source-done
SRC_DIR         = $(TARGET_BUILD_DIR)/dialog-1.2-20140112
SRC_ARCHIVE     = $(tar_gz_archive)

PATCHES = PATCHES

build_target    = $(TARGET_BUILD_DIR)/.built
install_target  = $(TARGET_BUILD_DIR)/.installed

environment     =
extra_configure_switches  = --libdir=/usr/lib
extra_configure_switches += --mandir=/usr/share/man
extra_configure_switches += --without-shared
extra_configure_switches += --with-ncursesw

BUILD_TARGETS = $(install_target)

include ../../../../build-system/core.mk

$(src_done): $(SRC_ARCHIVE) $(PATCHES_DEP)
	$(UNPACK_SRC_ARCHIVE)
	$(APPLY_PATCHES)
	@touch $@

$(build_target): $(src_done)
	@mkdir -p $(build_dir)
	@cd $(build_dir) && $(environment) ../$(src_dir)/configure \
	  --prefix=/ \
	  $(extra_configure_switches)
	@$(environment) $(MAKE) -C $(build_dir) all
	@touch $@

$(install_target): $(build_target)
	@echo -e "\n======= Installing DIALOG binary =======\n"
	@mkdir -p $(BUILDSYSTEM)/sbin && \
	  cp -a $(build_dir)/dialog $(BUILDSYSTEM)/sbin && \
	  echo "DIALOG := $(BUILDSYSTEM)/sbin/dialog" >> $(BUILDSYSTEM)/sbin/.config
	@touch $@
