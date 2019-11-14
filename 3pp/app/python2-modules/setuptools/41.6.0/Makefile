
COMPONENT_TARGETS = $(HARDWARE_BUILD)

include ../../../../../../build-system/constants.mk

SOURCE_REQUIRES = build-system/3pp/sources/packages/python2-modules/setuptools

REQUIRES = build-system/3pp/app/python2/2.7.16

# ======= __END_OF_REQUIRES__ =======

version         = 41.6.0
tar_gz_archive  = $(BUILDSYSTEM)/3pp/sources/packages/python2-modules/setuptools/setuptools-$(version).tar.gz
SRC_ARCHIVE     = $(tar_gz_archive)
SRC_DIR         = $(TARGET_BUILD_DIR)/setuptools-$(version)
src_done        = $(TARGET_BUILD_DIR)/.source-done

PATCHES = PATCHES

build_target    = $(TARGET_BUILD_DIR)/.built
install_target  = $(TARGET_BUILD_DIR)/.installed

BUILD_TARGETS = $(install_target)

include ../../../../../../build-system/core.mk

$(src_done): $(SRC_ARCHIVE) $(PATCHES_DEP)
	$(UNPACK_SRC_ARCHIVE)
	$(APPLY_PATCHES)
	@touch $@

$(build_target): $(src_done)
	@( cd $(SRC_DIR) ; \
	   $(BUILDSYSTEM)/usr/bin/python2 bootstrap.py   ; \
	   $(BUILDSYSTEM)/usr/bin/python2 setup.py build ; \
	 )
	@touch $@

$(install_target): $(build_target)
	@echo -e "\n======= Installing setuptools-$(version) =======\n"
	@( cd $(SRC_DIR) ; \
	   $(BUILDSYSTEM)/usr/bin/python2 setup.py install ; \
	 )
	@touch $@
