
COMPONENT_TARGETS = $(HARDWARE_BUILD)

include ../../../../../build-system/constants.mk

SOURCE_REQUIRES = build-system/3pp/sources/packages/sqlite


# ======= __END_OF_REQUIRES__ =======

version         = 3.31.1.0
tar_gz_archive  = $(BUILDSYSTEM)/3pp/sources/packages/sqlite/sqlite-$(version).tar.gz
src_dir         = sqlite-$(version)
build_dir       = $(TARGET_BUILD_DIR)/built

src_done        = $(TARGET_BUILD_DIR)/.source-done
SRC_DIR         = $(TARGET_BUILD_DIR)/sqlite-$(version)
SRC_ARCHIVE     = $(tar_gz_archive)

PATCHES = PATCHES

build_target    = $(TARGET_BUILD_DIR)/.built
install_target  = $(TARGET_BUILD_DIR)/.installed

environment     =
extra_configure_switches  = --libdir=/usr/lib
extra_configure_switches += --docdir=/usr/share/doc/$(src_dir)
extra_configure_switches += --mandir=/usr/share/man
extra_configure_switches += --localstatedir=/var
extra_configure_switches += --enable-threadsafe=yes
extra_configure_switches += --enable-dynamic-extensions=yes
extra_configure_switches += --disable-dependency-tracking
extra_configure_switches += --enable-static=yes
extra_configure_switches += --enable-shared=yes

BUILD_TARGETS = $(install_target)

include ../../../../../build-system/core.mk

$(src_done): $(SRC_ARCHIVE) $(PATCHES_DEP)
	$(UNPACK_SRC_ARCHIVE)
	$(APPLY_PATCHES)
	@touch $@

$(build_target): $(src_done)
	@mkdir -p $(build_dir)
	@cd $(build_dir) && $(environment) ../$(src_dir)/configure \
	  --prefix=/usr \
	  $(extra_configure_switches)
	@$(environment) $(MAKE) -C $(build_dir) all
	@touch $@

$(install_target): $(build_target)
	@echo -e "\n======= Installing SQLite binary =======\n"
	@cd $(build_dir) && $(MAKE) install DESTDIR=$(BUILDSYSTEM)
	@touch $@
