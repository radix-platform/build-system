
COMPONENT_TARGETS = $(HARDWARE_BUILD)

include ../../../../../build-system/constants.mk

SOURCE_REQUIRES = build-system/3pp/sources/packages/populatefs


# ======= __END_OF_REQUIRES__ =======


version         = 1.1
tar_xz_archive  = $(BUILDSYSTEM)/3pp/sources/packages/populatefs/populatefs-$(version).tar.xz
src_dir         = populatefs-$(version)
build_dir       = $(TARGET_BUILD_DIR)/built

src_done        = $(TARGET_BUILD_DIR)/.source-done
SRC_DIR         = $(TARGET_BUILD_DIR)/populatefs-$(version)
SRC_ARCHIVE     = $(tar_xz_archive)

PATCHES = PATCHES

build_target    = $(TARGET_BUILD_DIR)/.built
install_target  = $(TARGET_BUILD_DIR)/.installed

BUILD_TARGETS = $(install_target)


include ../../../../../build-system/core.mk


environment     = prefix=/usr
environment    += bindir=/sbin
environment    += libdir=/usr/lib$(BUILD_MULTILIB_SUFFIX)
environment    += includedir=/usr/include
environment    += LDFLAGS=-L/usr/lib$(BUILD_MULTILIB_SUFFIX)


$(src_done): $(SRC_ARCHIVE) $(PATCHES_DEP)
	$(UNPACK_SRC_ARCHIVE)
	$(APPLY_PATCHES)
	@touch $@

$(build_target): $(src_done)
	@( cd $(SRC_DIR) ; \
	   $(MAKE) $(environment) ; \
	 )
	@touch $@

$(install_target): $(build_target)
	@echo -e "\n======= Installing POPULATEFS binary =======\n"
	@mkdir -p $(BUILDSYSTEM)/sbin && \
	  cp -a $(SRC_DIR)/src/populatefs $(BUILDSYSTEM)/sbin && \
	  echo "POPULATEFS         := $(BUILDSYSTEM)/sbin/populatefs" >> $(BUILDSYSTEM)/sbin/.config
	@touch $@
