
COMPONENT_TARGETS = $(HARDWARE_BUILD)

include ../../../../build-system/constants.mk

SOURCE_REQUIRES = build-system/3pp/sources/packages/genext2fs


# ======= __END_OF_REQUIRES__ =======


version         = 1.4.1
tar_gz_archive  = $(BUILDSYSTEM)/3pp/sources/packages/genext2fs/genext2fs-$(version).tar.gz
src_dir         = genext2fs-$(version)
build_dir       = $(TARGET_BUILD_DIR)/built

src_done        = $(TARGET_BUILD_DIR)/.source-done
SRC_DIR         = $(TARGET_BUILD_DIR)/genext2fs-$(version)
SRC_ARCHIVE     = $(tar_gz_archive)

PATCHES = PATCHES

build_target    = $(TARGET_BUILD_DIR)/.built
install_target  = $(TARGET_BUILD_DIR)/.installed

environment     =

BUILD_TARGETS = $(install_target)


include ../../../../build-system/core.mk


extra_configure_switches = --libdir=/usr/lib$(BUILD_MULTILIB_SUFFIX)

$(src_done): $(SRC_ARCHIVE) $(PATCHES_DEP)
	$(UNPACK_SRC_ARCHIVE)
	$(APPLY_PATCHES)
	@touch $@

$(build_target): $(src_done)
	@mkdir -p $(build_dir)
	@( cd $(SRC_DIR) ; \
	   autoreconf -i ; rm -rf autom4te.cache ; rm -f *~ ; \
	 )
	@cd $(build_dir) && $(environment) ../$(src_dir)/configure \
	  --prefix=/usr \
	  $(extra_configure_switches)
	@$(environment) $(MAKE) -C $(build_dir) all
	@touch $@

$(install_target): $(build_target)
	@echo -e "\n======= Installing genext2fs binary =======\n"
	@mkdir -p $(BUILDSYSTEM)/sbin && \
	  cp -a $(build_dir)/genext2fs $(BUILDSYSTEM)/sbin && \
	  echo "GENEXT2FS := $(BUILDSYSTEM)/sbin/genext2fs" >> $(BUILDSYSTEM)/sbin/.config
	@touch $@
