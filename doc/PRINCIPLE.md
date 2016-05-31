

The fundamental principle of the build system
=============================================

Assume that we need to build the program or alienated package for working
on the three devices with names **ci20**, **bt01** and **dm64**. The first two devices
(**ci20**, **bt01**) are based on the **MIPS** architecture, and the third device (**dm64**)
is built on **ARM**-based processor. Toolchains for building our program, for
simplicity, let's call **mips** and **arm**, respectively.

The build script of the source program is the same for each of our devices
and is written on **GNU Make**.

If we present all available combinations of command line calls, required for
building the program for our devices, we get:

```bash
 $ TOOLCHAIN=mips HARDWARE=ci20 make
 $ TOOLCHAIN=mips HARDWARE=bt01 make
 $ TOOLCHAIN=arm  HARDWARE=dm64 make
```

or (in case when the **TOOLCHAIN-HARDWARE** pairs are transmitted as arguments):

```bash
 $ make TOOLCHAIN=mips HARDWARE=ci20
 $ make TOOLCHAIN=mips HARDWARE=bt01
 $ make TOOLCHAIN=arm  HARDWARE=dm64
```

Thus, the **build system** must receive a **TOOLCHAIN-HARDWARE** pair, and then the
**build system** has to determine which toolchain must be used for a particular
device.

Let us now consider how to organize the sequence of command calls (on the
**build system** level) in such way that the user can do these actions by
applying only one call:

```bash
 $ make
```

without specifying additional arguments which are responsible for selection
of the target device and applicable toolchain.

If we describe the list of valid terget devices at the beginning of our script,
for example, as follows:

```make
COMPONENT_TARGETS  = $(HARDWARE_CI20)
COMPONENT_TARGETS += $(HARDWARE_BT01)
COMPONENT_TARGETS += $(HARDWARE_DM64)
```

then the **build system** can automatically construct a list of possible
**TOOLCHAIN-HARDWARE** combinations for a given build script, which will looks
like following:

```make
  targets = target_mips_ci20 target_mips_bt01 target_arm_dm64
```

With such list, the **build system** can restore arguments which are needed for
each of three our calls. It is very simple to do. On the **GNU Make** language we can
do it as shown by following lines:

```make
target_%: TOOLCHAIN = $(shell echo $(word 2, $(subst _, , $@)))
target_%: HARDWARE = $(shell echo $(word 3, $(subst _, , $@)))
target_%:
	$(MAKE) TOOLCHAIN=$(TOOLCHAIN) HARDWARE=$(HARDWARE)
```

Thus, if we call the **Make** utility without arguments then **TOOLCHAIN** and **HARDWARE**
variables will be undefined. In this case the **build system** starts to collect the
targets list. When the **targets** list will be complete the **build system** can do the
call

```make
	$(MAKE) TOOLCHAIN=$(TOOLCHAIN) HARDWARE=$(HARDWARE)
```

with valid arguments.

When (at the next call) the system will make sure that the **TOOLCHAIN** and
**HARDWARE** variables are defined, the control of the build process will be passed
to our build script without additional calculations.

The described mechanism is directly derived from the **GNU Make** documentation.


References
----------
1. <http://www.gnu.org/software/make/manual/>
2. <https://radix.pro/build-system/>

