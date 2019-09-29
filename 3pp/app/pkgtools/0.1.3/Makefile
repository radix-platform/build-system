
COMPONENT_TARGETS = $(HARDWARE_BUILD)

include ../../../../../build-system/constants.mk

SOURCE_REQUIRES = build-system/3pp/sources/packages/pkgtools

REQUIRES = build-system/3pp/app/dialog/1.3-20190808

# ======= __END_OF_REQUIRES__ =======


tar_xz_archive  = $(BUILDSYSTEM)/3pp/sources/packages/pkgtools/pkgtools-0.1.3.tar.xz
src_dir         = pkgtools-0.1.3
build_dir       = $(TARGET_BUILD_DIR)/built

src_done        = $(TARGET_BUILD_DIR)/.source-done
SRC_DIR         = $(TARGET_BUILD_DIR)/pkgtools-0.1.2
SRC_ARCHIVE     = $(tar_xz_archive)

PATCHES = PATCHES

build_target    = $(TARGET_BUILD_DIR)/.built
install_target  = $(TARGET_BUILD_DIR)/.installed

environment     = CPPFLAGS=-I$(BUILDSYSTEM)/usr/include
environment    += LDFLAGS=-Wl,-rpath=$(BUILDSYSTEM)/usr/lib

extra_configure_switches += --with-dialog=$(BUILDSYSTEM)/usr
extra_configure_switches += --with-dialog-test=yes
extra_configure_switches += --with-gpg2=yes
extra_configure_switches += --with-distro-name=$(DISTRO_NAME)
extra_configure_switches += --with-distro-version=$(DISTRO_VERSION)

BUILD_TARGETS = $(install_target)

include ../../../../../build-system/core.mk

$(src_done): $(SRC_ARCHIVE) $(PATCHES_DEP)
	$(UNPACK_SRC_ARCHIVE)
	$(APPLY_PATCHES)
	@touch $@

$(build_target): $(src_done)
	@cd $(SRC_DIR) && ./bootstrap
	@mkdir -p $(build_dir)
	@cd $(build_dir) && $(environment) ../$(src_dir)/configure \
	  --prefix=$(BUILDSYSTEM)/usr \
	  --sbindir=$(BUILDSYSTEM)/sbin \
	  --build=$(BUILD) \
	  --host=$(BUILD)  \
	  $(extra_configure_switches)
	@$(environment) $(MAKE) -C $(build_dir) all
	@touch $@

$(install_target): $(build_target)
	@echo -e "\n======= Installing PKGTOOLS binaries =======\n"
	@$(environment) $(MAKE) -j1 -C $(build_dir) install
	@mkdir -p $(BUILDSYSTEM)/sbin && \
	  echo "CHECK_DB_INTEGRITY := $(BUILDSYSTEM)/sbin/check-db-integrity" >> $(BUILDSYSTEM)/sbin/.config && \
	  echo "CHECK_PACKAGE      := $(BUILDSYSTEM)/sbin/check-package"      >> $(BUILDSYSTEM)/sbin/.config && \
	  echo "CHECK_REQUIRES     := $(BUILDSYSTEM)/sbin/check-requires"     >> $(BUILDSYSTEM)/sbin/.config && \
	  echo "CHANGE_REFS        := $(BUILDSYSTEM)/sbin/chrefs"             >> $(BUILDSYSTEM)/sbin/.config && \
	  echo "INSTALL_PACKAGE    := $(BUILDSYSTEM)/sbin/install-package"    >> $(BUILDSYSTEM)/sbin/.config && \
	  echo "INSTALL_PKGLIST    := $(BUILDSYSTEM)/sbin/install-pkglist"    >> $(BUILDSYSTEM)/sbin/.config && \
	  echo "MAKE_PACKAGE       := $(BUILDSYSTEM)/sbin/make-package"       >> $(BUILDSYSTEM)/sbin/.config && \
	  echo "MAKE_PKGLIST       := $(BUILDSYSTEM)/sbin/make-pkglist"       >> $(BUILDSYSTEM)/sbin/.config && \
	  echo "PKGINFO            := $(BUILDSYSTEM)/sbin/pkginfo"            >> $(BUILDSYSTEM)/sbin/.config && \
	  echo "PKGLOG             := $(BUILDSYSTEM)/sbin/pkglog"             >> $(BUILDSYSTEM)/sbin/.config && \
	  echo "REMOVE_PACKAGE     := $(BUILDSYSTEM)/sbin/remove-package"     >> $(BUILDSYSTEM)/sbin/.config && \
	  echo "UPDATE_PACKAGE     := $(BUILDSYSTEM)/sbin/update-package"     >> $(BUILDSYSTEM)/sbin/.config
	@touch $@
