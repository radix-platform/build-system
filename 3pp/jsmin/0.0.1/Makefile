
COMPONENT_TARGETS = $(HARDWARE_BUILD)

include ../../../../build-system/constants.mk

SOURCE_REQUIRES = build-system/3pp/sources/packages/jsmin


# ======= __END_OF_REQUIRES__ =======


tar_gz_archive  = $(BUILDSYSTEM)/3pp/sources/packages/jsmin/jsmin-0.0.1.tar.gz
src_dir         = jsmin-0.0.1
build_dir       = $(TARGET_BUILD_DIR)/built

src_done        = $(TARGET_BUILD_DIR)/.source-done
SRC_DIR         = $(TARGET_BUILD_DIR)/jsmin-0.0.1
SRC_ARCHIVE     = $(tar_gz_archive)

build_target    = $(TARGET_BUILD_DIR)/.built
install_target  = $(TARGET_BUILD_DIR)/.installed

environment     =

extra_configure_switches  = --program-prefix=''
extra_configure_switches += --program-suffix=''

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
	@touch $@

$(install_target): $(build_target)
	@echo -e "\n======= Installing JSMIN binary =======\n"
	@mkdir -p $(BUILDSYSTEM)/sbin && \
	  cp -a $(build_dir)/src/jsmin     $(BUILDSYSTEM)/sbin && \
	  echo "JSMIN := $(BUILDSYSTEM)/sbin/jsmin" >> $(BUILDSYSTEM)/sbin/.config
	@touch $@
