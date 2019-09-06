
COMPONENT_TARGETS = $(HARDWARE_BUILD)

include ../../../../../build-system/constants.mk

SOURCE_REQUIRES = build-system/3pp/sources/packages/dialog


# ======= __END_OF_REQUIRES__ =======


tar_gz_archive  = $(BUILDSYSTEM)/3pp/sources/packages/dialog/dialog-1.3-20190808.tgz
src_dir         = dialog-1.3-20190808
build_dir       = $(TARGET_BUILD_DIR)/built

src_done        = $(TARGET_BUILD_DIR)/.source-done
SRC_DIR         = $(TARGET_BUILD_DIR)/dialog-1.3-20190808
SRC_ARCHIVE     = $(tar_gz_archive)

PATCHES = PATCHES

build_target    = $(TARGET_BUILD_DIR)/.built
install_target  = $(TARGET_BUILD_DIR)/.installed

environment     =
extra_configure_switches += --mandir=$(BUILDSYSTEM)/usr/share/man
extra_configure_switches += --with-shared
extra_configure_switches += --with-libtool
extra_configure_switches += --with-ncursesw
extra_configure_switches += --enable-widec

BUILD_TARGETS = $(install_target)

include ../../../../../build-system/core.mk

$(src_done): $(SRC_ARCHIVE) $(PATCHES_DEP)
	$(UNPACK_SRC_ARCHIVE)
	$(APPLY_PATCHES)
	@touch $@

$(build_target): $(src_done)
	@mkdir -p $(build_dir)
	@cd $(build_dir) && $(environment) ../$(src_dir)/configure \
	  --prefix=$(BUILDSYSTEM)/usr \
	  --exec-prefix=$(BUILDSYSTEM)/usr \
	  --build=$(BUILD) \
	  --host=$(BUILD)  \
	  $(extra_configure_switches)
	@$(environment) $(MAKE) -C $(build_dir) all
	@touch $@

$(install_target): $(build_target)
	@echo -e "\n======= Installing DIALOG binary =======\n"
	@$(environment) $(MAKE) -j1 -C $(build_dir) install
	@sed -i '/^#include <dlg_config.h>/,+1d' $(BUILDSYSTEM)/usr/include/dialog.h
	@rm -f $(BUILDSYSTEM)/usr/include/dlg_config.h
	@chmod 755 $(BUILDSYSTEM)/usr/lib/libdialog.{la,so*}
	@mkdir -p $(BUILDSYSTEM)/usr/share/aclocal
	@cat $(SRC_DIR)/dialog.m4 > $(BUILDSYSTEM)/usr/share/aclocal/dialog.m4
	@chmod 644 $(BUILDSYSTEM)/usr/share/aclocal/dialog.m4
	@mkdir -p $(BUILDSYSTEM)/sbin && \
	  echo "DIALOG             := $(BUILDSYSTEM)/usr/bin/dialog"        >> $(BUILDSYSTEM)/sbin/.config && \
	  echo "DIALOG_CONFIG      := $(BUILDSYSTEM)/usr/bin/dialog-config" >> $(BUILDSYSTEM)/sbin/.config
	@touch $@
