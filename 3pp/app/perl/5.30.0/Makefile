
COMPONENT_TARGETS = $(HARDWARE_BUILD)

include ../../../../../build-system/constants.mk

SOURCE_REQUIRES = build-system/3pp/sources/packages/perl


# ======= __END_OF_REQUIRES__ =======

version         = 5.30.0
tar_xz_archive  = $(BUILDSYSTEM)/3pp/sources/packages/perl/perl-$(version).tar.xz
SRC_ARCHIVE     = $(tar_xz_archive)
SRC_DIR         = $(TARGET_BUILD_DIR)/perl-$(version)
src_done        = $(TARGET_BUILD_DIR)/.source-done

PATCHES = PATCHES

build_target    = $(TARGET_BUILD_DIR)/.built
install_target  = $(TARGET_BUILD_DIR)/.installed


ARCH     = $(shell uname -m)
ARCHNAME = $(ARCH)-linux

OPTIMIZE = -O2

ifeq ($(ARCH),x86_64)
  ARCH_OPTS  = -Dcccdlflags='-fPIC' -Duselargefiles -Duse64bitall
  OPTIMIZE  += -fPIC
endif

OPTIMIZE += -Wno-cast-function-type -Wno-nonnull -Wno-clobbered
OPTIMIZE += -Wno-multistatement-macros -Wimplicit-fallthrough=0

#
# If after all this time you still don't trust threads, comment out the variable below:
#
USE_THREADS = -Dusethreads -Duseithreads


extra_configure_switches  = -Darchname=$(ARCHNAME)

extra_configure_switches += -Dprefix=$(BUILDSYSTEM)/usr
extra_configure_switches += -Dbin='$(BUILDSYSTEM)/usr/bin'
extra_configure_switches += -Dscriptdir='$(BUILDSYSTEM)/usr/bin'

extra_configure_switches += -Darchlib='$(BUILDSYSTEM)/usr/lib/perl5'
extra_configure_switches += -Dprivlib='$(BUILDSYSTEM)/usr/share/perl5'

extra_configure_switches += -Dsiteprefix=$(BUILDSYSTEM)/usr
extra_configure_switches += -Dsitebin='$(BUILDSYSTEM)/usr/bin'
extra_configure_switches += -Dsitescript='$(BUILDSYSTEM)/usr/bin'
extra_configure_switches += -Dsitearch='$(BUILDSYSTEM)/usr/lib/perl5/site_perl'
extra_configure_switches += -Dsitelib='$(BUILDSYSTEM)/usr/share/perl5/site_perl'

extra_configure_switches += -Dvendorprefix=$(BUILDSYSTEM)/usr
extra_configure_switches += -Dvendorbin='$(BUILDSYSTEM)/usr/bin'
extra_configure_switches += -Dvendorscript='$(BUILDSYSTEM)/usr/bin'
extra_configure_switches += -Dvendorarch='$(BUILDSYSTEM)/usr/lib/perl5/vendor_perl'
extra_configure_switches += -Dvendorlib='$(BUILDSYSTEM)/usr/share/perl5/vendor_perl'

extra_configure_switches += -Dinstallprefix=$(BUILDSYSTEM)/usr
extra_configure_switches += -Dlibpth='$(BUILDSYSTEM)/usr/lib'
extra_configure_switches += -Dloclibpth='$(BUILDSYSTEM)/usr/lib'
extra_configure_switches += -Dlocincpth='$(BUILDSYSTEM)/usr/include'

extra_configure_switches += -Doptimize='$(OPTIMIZE)'
extra_configure_switches += $(USE_THREADS)
extra_configure_switches += $(ARCH_OPTS)
extra_configure_switches += -Duseshrplib
extra_configure_switches += -Ubincompat5005
extra_configure_switches += -Uversiononly

extra_configure_switches += -Dpager='/usr/bin/less -isr'

extra_configure_switches += -Dhtml1dir='$(BUILDSYSTEM)/usr/share/doc/perl-$(version)/html'
extra_configure_switches += -Dhtml3dir='$(BUILDSYSTEM)/usr/share/doc/perl-$(version)/html'
extra_configure_switches += -Dman1dir='$(BUILDSYSTEM)/usr/share/man/man1'
extra_configure_switches += -Dman3dir='$(BUILDSYSTEM)/usr/share/man/man3'


BUILD_TARGETS = $(install_target)

include ../../../../../build-system/core.mk

$(src_done): $(SRC_ARCHIVE) $(PATCHES_DEP)
	$(UNPACK_SRC_ARCHIVE)
	$(APPLY_PATCHES)
	@cd $(SRC_DIR) && echo 'installstyle="lib/perl5"' >> hints/linux.sh
	@touch $@

$(build_target): $(src_done)
	@cd $(SRC_DIR) && ./Configure -des $(extra_configure_switches)
	@cd $(SRC_DIR) && $(MAKE)
	@touch $@

$(install_target): $(build_target)
	@echo -e "\n======= Installing Perl 5 binary =======\n"
	@cd $(SRC_DIR) && $(MAKE) -j1 install
	@echo -e "\n======= Setup PERL build-system variable =======\n"
	@mkdir -p $(BUILDSYSTEM)/sbin && \
	  echo "PERL               := $(BUILDSYSTEM)/usr/bin/perl" >> $(BUILDSYSTEM)/sbin/.config
	@touch $@
