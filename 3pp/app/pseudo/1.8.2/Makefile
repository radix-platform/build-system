
COMPONENT_TARGETS = $(HARDWARE_BUILD)

include ../../../../../build-system/constants.mk

SOURCE_REQUIRES = build-system/3pp/sources/packages/pseudo

REQUIRES        = build-system/3pp/app/sqlite/3.31.1.0

# ======= __END_OF_REQUIRES__ =======

version         = 1.8.2
tar_xz_archive  = $(BUILDSYSTEM)/3pp/sources/packages/pseudo/pseudo-$(version).tar.xz
SRC_ARCHIVE     = $(tar_xz_archive)
SRC_DIR         = $(TARGET_BUILD_DIR)/pseudo-$(version)

src_done        = $(TARGET_BUILD_DIR)/.source-done
src_dir_name    = pseudo-$(version)
build_dir       = $(TARGET_BUILD_DIR)/built

PATCHES = PATCHES

build_target    = $(TARGET_BUILD_DIR)/.built
install_target  = $(TARGET_BUILD_DIR)/.installed

pseudo_wrapper    = $(CURDIR)/scripts/pseudo.pl
pseudolog_wrapper = $(CURDIR)/scripts/pseudolog

environment     = CPPFLAGS=-I$(BUILDSYSTEM)/usr/include
environment    += LDFLAGS=-Wl,-rpath=$(BUILDSYSTEM)/usr/lib

extra_configure_switches += --libdir=/usr/lib
extra_configure_switches += --with-sqlite=$(BUILDSYSTEM)/usr
extra_configure_switches += --bits=64
extra_configure_switches += --enable-memory-db
extra_configure_switches += --cflags='-m64 -Wimplicit-fallthrough=0'


BUILD_TARGETS = $(install_target)

include ../../../../../build-system/core.mk

$(src_done): $(SRC_ARCHIVE) $(PATCHES_DEP)
	$(UNPACK_SRC_ARCHIVE)
	$(APPLY_PATCHES)
	@touch $@

$(build_target): $(src_done)
	@( cd $(SRC_DIR) ; \
	   $(environment) ./configure --prefix=/usr $(extra_configure_switches) ; \
	   $(environment) $(MAKE) LOCALSTATE=../var/pseudo ; \
	 )
	@touch $@

$(install_target): $(build_target)
	@echo -e "\n======= Installing PSEUDO binary =======\n"
	@( cd $(SRC_DIR) ; \
	   $(MAKE) install LOCALSTATE=../var/pseudo DESTDIR=$(BUILDSYSTEM) ; \
	   mkdir -p $(BUILDSYSTEM)/usr/share/man/man1 ; \
	   cp pseudo.1 pseudolog.1 $(BUILDSYSTEM)/usr/share/man/man1 ; \
	 )
	@echo -e "\n======= Installing PSEUDO and PSEUDOLOG wrappers =======\n"
	@mkdir -p $(BUILDSYSTEM)/sbin && \
	  cp -a $(pseudo_wrapper) $(BUILDSYSTEM)/sbin/pseudo && \
	  chmod a+x $(BUILDSYSTEM)/sbin/pseudo               && \
	  echo "PSEUDO             := $(BUILDSYSTEM)/sbin/pseudo" >> $(BUILDSYSTEM)/sbin/.config
	@cp -a $(pseudolog_wrapper) $(BUILDSYSTEM)/sbin/pseudolog && \
	 chmod a+x $(BUILDSYSTEM)/sbin/pseudolog                  && \
	 echo "PSEUDOLOG          := $(BUILDSYSTEM)/sbin/pseudolog" >> $(BUILDSYSTEM)/sbin/.config
	@touch $@
