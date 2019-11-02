
COMPONENT_TARGETS = $(HARDWARE_BUILD)

include ../../../../../build-system/constants.mk

SOURCE_REQUIRES = build-system/3pp/sources/packages/python3


# ======= __END_OF_REQUIRES__ =======

version         = 3.7.4
tar_xz_archive  = $(BUILDSYSTEM)/3pp/sources/packages/python3/Python-$(version).tar.xz
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
python_environment += PYTHONHOME=$(BUILDSYSTEM)/usr/lib/python3.7
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
	@echo -e "\n======= Installing Python 3.7 binary =======\n"
	@cd $(SRC_DIR) && $(MAKE) -j1 $(python_environment) install
	@cp -a $(SRC_DIR)/Parser/pgen $(BUILDSYSTEM)/usr/bin/pgen3.7
	@( cd $(BUILDSYSTEM)/usr/bin ; ln -sf pgen3.7 pgen3 )
	@echo -e "\n======= tune python3.7m-config CFLAGS for target machine =======\n"
	@( cd $(BUILDSYSTEM)/usr/bin ; \
	   sed -i 's,includedir=$$(echo "$${prefix},includedir=$$(echo "/usr,g' python3.7m-config ; \
	   sed -i 's,LIBPL=$$(echo "$${prefix},LIBPL=$$(echo "/usr,g' python3.7m-config ; \
	   sed -i "s,$(BUILDSYSTEM),,g" python3.7m-config ; \
	 )
	@( cd $(BUILDSYSTEM)/usr/include/python3.7m ; \
	   mv pyconfig.h pyconfig-64.h ; \
	   echo ''                                               > pyconfig.h ; \
	   echo '/******************************'               >> pyconfig.h ; \
	   echo '  pyconfig.h - Multilib Header'                >> pyconfig.h ; \
	   echo ' ******************************/'              >> pyconfig.h ; \
	   echo ''                                              >> pyconfig.h ; \
	   echo '#ifndef __MULTILIB__PYCONFIG_H__'              >> pyconfig.h ; \
	   echo '#define __MULTILIB__PYCONFIG_H__'              >> pyconfig.h ; \
	   echo ''                                              >> pyconfig.h ; \
	   echo '#if defined(__x86_64__)    || \'               >> pyconfig.h ; \
	   echo '    defined(__aarch64__)   || \'               >> pyconfig.h ; \
	   echo '    defined(__powerpc64__) || \'               >> pyconfig.h ; \
	   echo '    defined(__sparc__) && defined(__arch64__)' >> pyconfig.h ; \
	   echo '#include "pyconfig-64.h"'                      >> pyconfig.h ; \
	   echo '#else'                                         >> pyconfig.h ; \
	   echo '#include "pyconfig-32.h"'                      >> pyconfig.h ; \
	   echo '#endif'                                        >> pyconfig.h ; \
	   echo ''                                              >> pyconfig.h ; \
	   echo '#endif /* __MULTILIB__PYCONFIG_H__ */'         >> pyconfig.h ; \
	   cat pyconfig-64.h | \
	     sed -e 's,^#define HAVE_GCC_ASM_FOR_X64 1,\/\* #undef HAVE_GCC_ASM_FOR_X64 \*\/,'     \
	         -e 's,^#define HAVE_GCC_UINT128_T 1,/* #undef HAVE_GCC_UINT128_T */,'             \
	         -e 's,^\/\* #undef HAVE_LARGEFILE_SUPPORT \*\/,#define HAVE_LARGEFILE_SUPPORT 1,' \
	         -e 's,^#define SIZEOF_LONG 8,#define SIZEOF_LONG 4,'                              \
	         -e 's,^#define SIZEOF_LONG_DOUBLE 16,#define SIZEOF_LONG_DOUBLE 12,'              \
	         -e 's,^#define SIZEOF_PTHREAD_T 8,#define SIZEOF_PTHREAD_T 4,'                    \
	         -e 's,^#define SIZEOF_SIZE_T 8,#define SIZEOF_SIZE_T 4,'                          \
	         -e 's,^#define SIZEOF_TIME_T 8,#define SIZEOF_TIME_T 4,'                          \
	         -e 's,^#define SIZEOF_UINTPTR_T 8,#define SIZEOF_UINTPTR_T 4,'                    \
	         -e 's,^#define SIZEOF_VOID_P 8,#define SIZEOF_VOID_P 4,'                          \
	     > pyconfig-32.h ; \
	 )
	@echo -e "\n======= Setup PYTHON3 build-system variable =======\n"
	@mkdir -p $(BUILDSYSTEM)/sbin && \
	  echo "PYTHON3            := $(BUILDSYSTEM)/usr/bin/python3" >> $(BUILDSYSTEM)/sbin/.config ; \
	  echo "PGEN3              := $(BUILDSYSTEM)/usr/bin/pgen3"   >> $(BUILDSYSTEM)/sbin/.config
	@touch $@
