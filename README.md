
# [Build System](https://radix.pro/build-system/)

**Build System** is a set of Makefiles and utilities organized within one directory which is mounted
into the source tree of the developed product.

> The main purpose of the **Build System** is automating all stages of software solution development,
> from arrangement of source code from third-party developers usage to publication of own deliverable
> distributive.

The fundamental principle of **Build System** is described in the
[Build System Internals](https://radix.pro/build-system/internals/#fundamental_principle) section and
in the [doc/PRINCIPLE*](doc/PRINCIPLE.md) files of this repository.


## Table of contents

* [Quick start](#user-content-quick-start)
* [Documentation](#user-content-documentation)
* [Community](#user-content-community)
* [Creators](#user-content-creators)


## Quick start

All steps described below are considered in the [Build System in Practice](https://radix.pro/build-system/practice/)
section on the main [Radix.pro](https://radix.pro) site. To create first package using
[Build System](https://radix.pro/build-system/) we have to perform following steps:

* [Install CCACHE](#user-content-install-ccache)
* [Getting Toolchains](#user-content-getting-toolchains)
* [Create a First Package](#user-content-first-package)


### Install CCACHE

To speed up the building process we strongly recommend to set up **CCACHE**(**1**) utility. Almost all **Linux**
distributions have this utility by default.

We described **CCACHE** setup process in the [Build System Overview](https://radix.pro/build-system/overview/#ccache)
section and here we have to notice that the directory */opt/extra/ccache* is a default place of the **CCACHE** data.
If you want to use another directory for **CCACHE** data then you have to change the value of **CACHED_CC_OUTPUT**
variable in the [constants.mk](constants.mk) file. Of course all developers should to have permissions to access
this directory.

Before start the first build process you have to create **CCACHE** data directory on behalf of superuser:

```Bash
$ sudo mkdir -p /opt/extra/ccache
$ sudo chown -R developer:developers /opt/extra
```

Where **developers** - is a name your developers group and **developer** - is a name of some user who is
a member of **developers** group.


### Getting Toolchains

First of all we have to create toolchains directory on the developer machine. The default path to toolchains
is defined by **TOOLCHAINS_BASE_PATH** variable in the [constants.mk](constants.mk) file. The access permissions
should be given to developers by the superuser:

```Bash
$ sudo mkdir -p /opt/toolchain
$ sudo chown -R developer:developers /opt/toolchain
```

In principle no additional actions from the user is not required. The fact is that if before the start
of assembly the first package the required toolchain will not be found in the appropriate directory then
the **build system will** start downloading the needed toolchain from **FTP**-server and at the end of the
downloading the **build system** unpacks the toolchain to the */opt/toolchain*  directory.

Also the toolchains installation can be done manualy. To do this you have to perform a set of commands
like following:

```Bash
$ cd /opt/toolchain
$ wget ftp://ftp.radix.pro/toolchains/x86_64/1.0.9/arm-RK328X-linux-glibc-1.0.9.tar.gz
$ tar xzf arm-RK328X-linux-glibc-1.0.9.tar.gz
```

for each needed toolchain.


### First Package

Consider the work of the **build system** on the simplest example which despite its simplicity allow us
to explore all of main stages of creating distributable packages.

Let us create a project directory:

```Bash
$ mkdir project
$ cd project
```

Clone the **build system** repository:

```Bash
$ git clone https://github.com/radix-platform/build-system.git
```

At this stage we do not want to create a new package from scratch and consider a complete package from
[Radix Platform](http://svn.radix.pro/wsvn/platform/) repository. Let it be **pkgtool**. The **pkgtool** -
is a base package which does not require the downloading any sources as they already present in the
**build system**. In addition, **pkgtool** does not depend on any packages in the system and we
already have all needed tools presented on the developer's machine.

So, to obtain the necessary files we have to check out */base* directory from repository:

```Bash
$ svn co http://svn.radix.pro/svn/platform/trunk/base base
```

Let's change current directory to *base/pkgtool*:

```Bash
$ cd base/pkgtool
```

and create our first package:


```Bash
$ HARDWARE=ffrk3288 make
```

At the end of build process the **build system** displays a message indicating that the **pkgtool** package
has been successfully installed into *dist/rootfs/rk328x-glibc/ffrk3288* directory which created especially
as the working image of the target root file system:

```
Package creation complete.

#######
####### Install packages into 'dist/rootfs/rk328x-glibc/ffrk3288/...' file system...
#######

 Installing package pkgtool... 
|======================================================================|

 pkgtool 1.1.0 (Package Tools)
 
 This is a set of scripts used for package creation, install, etc.
 
 
 
 
 
 
 
 
 Uncompressed Size: 168K
   Compressed Sise: 24K
|======================================================================|

make[2]: Leaving directory `project/base/pkgtool'
make[1]: Leaving directory `project/base/pkgtool'
$
```

This process considered in more details in the [Build System in Practice](https://radix.pro/build-system/practice/#first_package)
section at the main [Radix.pro](https://radix.pro/) site.


## Documentation

**Build System**'s documentation is present on the main [Radix.pro](https://radix.pro) site
in the [Build System](https://radix.pro/build-system) section.


## Community

Get updates on **Build System**'s development and chat with the project maintainers and community members.

* Read and subscribe to [The Official Radix.pro Blog](https://blog.radix.pro).
* Follow [@RadixPlatform on Twitter](https://twitter.com/RadixPlatform).
* Read and subscribe to [The Official Radix.pro Facebook page](https://www.facebook.com/RadixPlatform).
* Join [The Official Radix.pro VKontakte group](https://vk.com/radixplatform).
* Read and subscribe to [The Official Radix.pro Google+ page](https://plus.google.com/104378627275746652509).
* Read and follow [The Official Radix.pro Tumblr blog](https://radix-platform.tumblr.com).


## Versioning

For transparency into our release cycle and in striving to maintain backward compatibility,
**Build System** is maintained under [the Semantic Versioning guidelines](http://semver.org/)
excluding additional labels such as pre-release suffixes. 

See [the Versioning section](https://radix.pro/build-system/overview/#versioning) on the main
[Radix.pro](https://radix.pro) site.

Release announcement posts will be available on [the Official Radix.pro Blog](https://blog.radix.pro) and
on the [Community](#user-content-community) sites.


## Creators

**Andrey V. Kosteltsev**

* <https://twitter.com/AKosteltsev>
* <https://www.facebook.com/andrey.kosteltsev>
* <https://vk.com/andrey.kosteltsev>


## Copyright and license

Code and documentation copyright 2009-2016 Andrey V. Kosteltsev.
Code and documentation released under [the **Radix.pro** License](LICENSE).
