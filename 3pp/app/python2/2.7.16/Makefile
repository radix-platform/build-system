
COMPONENT_TARGETS = $(HARDWARE_BUILD)

include ../../../../../build-system/constants.mk

SOURCE_REQUIRES = build-system/3pp/sources/packages/python2


# ======= __END_OF_REQUIRES__ =======

version         = 2.7.16
tar_xz_archive  = $(BUILDSYSTEM)/3pp/sources/packages/python2/Python-$(version).tar.xz
SRC_ARCHIVE     = $(tar_xz_archive)
SRC_DIR         = $(TARGET_BUILD_DIR)/Python-$(version)
src_done        = $(TARGET_BUILD_DIR)/.source-done

PATCHES = PATCHES

build_target    = $(TARGET_BUILD_DIR)/.built
install_target  = $(TARGET_BUILD_DIR)/.installed


LDFLAGS    += -Wl,-rpath,$(BUILDSYSTEM)/usr/lib

extra_configure_switches  = --libdir=$(BUILDSYSTEM)/usr/lib
extra_configure_switches += --bindir=$(BUILDSYSTEM)/usr/bin
extra_configure_switches += --docdir=$(BUILDSYSTEM)/usr/share/doc/$(src_dir_name)
extra_configure_switches += --mandir=$(BUILDSYSTEM)/usr/share/man
extra_configure_switches += --with-system-expat
extra_configure_switches += --with-system-ffi
extra_configure_switches += --with-threads
extra_configure_switches += --enable-ipv6
extra_configure_switches += --enable-shared

python_environment  = RFS=$(BUILDSYSTEM)
python_environment += PYTHONHOME=$(BUILDSYSTEM)/usr/lib/python2.7
python_environment += LDFLAGS='$(LDFLAGS)'


BUILD_TARGETS = $(install_target)

include ../../../../../build-system/core.mk

$(src_done): $(SRC_ARCHIVE) $(PATCHES_DEP)
	$(UNPACK_SRC_ARCHIVE)
	$(APPLY_PATCHES)
	@touch $@

$(build_target): $(src_done)
	@cd $(SRC_DIR) && $(python_environment) ./configure \
	  --prefix=$(BUILDSYSTEM)/usr \
	  --exec-prefix=$(BUILDSYSTEM)/usr \
	  --build=$(BUILD) \
	  --host=$(BUILD)  \
	  $(extra_configure_switches)
	@cd $(SRC_DIR) && $(python_environment) $(MAKE)
	@cd $(SRC_DIR) && $(python_environment) $(MAKE) Parser/pgen
	@touch $@

$(install_target): $(build_target)
	@echo -e "\n======= Installing Python 2.7 binary =======\n"
	@cd $(SRC_DIR) && $(MAKE) -j1 $(python_environment) install
	@cp -a $(SRC_DIR)/Parser/pgen $(BUILDSYSTEM)/usr/bin/
	@( cd $(BUILDSYSTEM)/usr/bin ; \
	   mv 2to3  2to3-2.7 ; ln -sf 2to3-2.7 2to3   ; \
	   mv idle  idle2.7  ; ln -sf idle2.7  idle2  ; ln -sf idle2  idle ; \
	   mv pydoc pydoc2.7 ; ln -sf pydoc2.7 pydoc2 ; ln -sf pydoc2 pydoc; \
	   mv pgen  pgen2.7  ; ln -sf pgen2.7  pgen2  ; ln -sf pgen2  pgen ; \
	 )
	@echo -e "\n======= Setup PYTHON2 build-system variable =======\n"
	@mkdir -p $(BUILDSYSTEM)/sbin && \
	  echo "PYTHON2            := $(BUILDSYSTEM)/usr/bin/python2" >> $(BUILDSYSTEM)/sbin/.config ; \
	  echo "PGEN2              := $(BUILDSYSTEM)/usr/bin/pgen2"   >> $(BUILDSYSTEM)/sbin/.config
	@touch $@
