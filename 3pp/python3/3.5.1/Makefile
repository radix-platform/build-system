
COMPONENT_TARGETS = $(HARDWARE_BUILD)

include ../../../../build-system/constants.mk

SOURCE_REQUIRES = build-system/3pp/sources/packages/python3


# ======= __END_OF_REQUIRES__ =======

version         = 3.5.1
tar_xz_archive  = $(BUILDSYSTEM)/3pp/sources/packages/python3/Python-$(version).tar.xz
SRC_ARCHIVE     = $(tar_xz_archive)
SRC_DIR         = $(TARGET_BUILD_DIR)/Python-$(version)
src_done        = $(TARGET_BUILD_DIR)/.source-done

PATCHES = PATCHES

build_target    = $(TARGET_BUILD_DIR)/.built
install_target  = $(TARGET_BUILD_DIR)/.installed

python_wrapper  = $(CURDIR)/scripts/python3


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
python_environment += PYTHONHOME=$(BUILDSYSTEM)/usr/lib/python3.5
python_environment += LDFLAGS='$(LDFLAGS)'


BUILD_TARGETS = $(install_target)

include ../../../../build-system/core.mk

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
	@touch $@

$(install_target): $(build_target)
	@echo -e "\n======= Installing Python 3.5 binary =======\n"
	@cd $(SRC_DIR) && $(MAKE) -j1 $(python_environment) install
	@echo -e "\n======= tune python3.5m-config CFLAGS for target machine =======\n"
	@( cd $(BUILDSYSTEM)/usr/bin ; \
	   sed -i 's,includedir=$$(echo "$${prefix},includedir=$$(echo "/usr,g' python3.5m-config ; \
	   sed -i 's,LIBPL=$$(echo "$${prefix},LIBPL=$$(echo "/usr,g' python3.5m-config ; \
	   sed -i "s,$(BUILDSYSTEM),,g" python3.5m-config ; \
	 )
	@echo -e "\n======= Installing Python3 wrapper =======\n"
	@mkdir -p $(BUILDSYSTEM)/sbin && \
	  cp -a $(python_wrapper) $(BUILDSYSTEM)/sbin/python3 && \
	  chmod a+x $(BUILDSYSTEM)/sbin/python3               && \
	  echo "PYTHON3 := $(BUILDSYSTEM)/sbin/python3" >> $(BUILDSYSTEM)/sbin/.config
	@touch $@
