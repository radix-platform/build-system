
COMPONENT_TARGETS = $(HARDWARE_BUILD)

include ../../../../../../build-system/constants.mk

SOURCE_REQUIRES = build-system/3pp/sources/packages/python2-modules/pip

REQUIRES = build-system/3pp/app/python2-modules/setuptools/46.1.3

# ======= __END_OF_REQUIRES__ =======

version         = 20.1
tar_gz_archive  = $(BUILDSYSTEM)/3pp/sources/packages/python2-modules/pip/pip-$(version).tar.gz
SRC_ARCHIVE     = $(tar_gz_archive)
SRC_DIR         = $(TARGET_BUILD_DIR)/pip-$(version)
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
	   $(BUILDSYSTEM)/usr/bin/python2 setup.py build ; \
	 )
	@touch $@

$(install_target): $(build_target)
	@echo -e "\n======= Installing setuptools-$(version) =======\n"
	@( cd $(SRC_DIR) ; \
	   $(BUILDSYSTEM)/usr/bin/python2 setup.py install ; \
	 )
	@( cd $(BUILDSYSTEM)/usr/bin ; \
	   rm -f pip ; ln -sf pip2 pip ; \
	 )
	@echo -e "\n======= Install Python2 M2Crypto package =======\n"
	@( cd $(BUILDSYSTEM)/usr/bin ; \
	   ./pip2.7 install M2Crypto ; \
	 )
	@echo -e "\n======= Setup PIP2 build-system variable =======\n"
	@mkdir -p $(BUILDSYSTEM)/sbin && \
	  echo "PIP2               := $(BUILDSYSTEM)/usr/bin/pip2"    >> $(BUILDSYSTEM)/sbin/.config
	@touch $@
