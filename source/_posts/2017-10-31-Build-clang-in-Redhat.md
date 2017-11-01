layout: post
title: 在Redhat6.8上编译安装clang
date: 2017-10-31 14:18:26
categories:
tags:
---


公司远程工作环境是redhat 6.8，gcc版本是4.4.7，还没有对C++11的完整支持。为了使用C++11，clang是一个很好的选择。
但开发环境虽然能够联网，但没有root权限，所以只好从源码编译安装。不得不说在Redhat上编译安装clang是个痛苦的过程=_=，我已经经历过了，所以把安装过程写了脚本，这样就可以很方便的在redhat上编译安装clang了。

clang is a great compiler, with a boatload of extremely helpful tools, including static analysis, run-time memory and data race analysis, and many others.

<!--more-->

## How to build

Like almost all compilers, clang is written in a high-level language (in this case C++), so building clang requires a host compiler to do the actual compilation.  On Linux this is almost always gcc, since it is ubiquitous on Linux machines.

There’s a hitch, though – as of version 3.3 some parts of clang are written in C++11, so the compiler used to compile clang needs to support the C++11 standard.

This is a real problem with RedHat, since the system compiler supplied with RedHat 6 (the most recent version that is in wide use), is gcc 4.4.7.  That compiler does not support C++11, and so is not able to compile clang.  So, the first step is getting a C++11-compliant compiler so we can compile clang.  For this example, we’re going to choose gcc 4.8.2, for a variety of reasons[^1].  The good news is that gcc 4.8.2 is written in C++ 98, so we can build it using the system compiler (gcc 4.4.7).


## Buid gcc 4.8.2

下面的脚本用于安装gcc 4.8.2。由于没有root权限，这里选择安装到用户目录`~/.local/share/gcc/4.8.2`下，这样我们需要在PATH和LD_LIBRARY_PATH中加入相对应的目录。

```bash
#!/bin/bash
set -exv

## modify the following as needed for your environment
# location where gcc should be installed
INSTALL_PREFIX=${HOME}/.local/share/gcc/4.8.2
# number of cores
CPUS=$(nproc)
# uncomment following to get verbose output from make
#VERBOSE=VERBOSE=1
# uncomment following if you need to sudo in order to do the install
#SUDO=sudo


## get everything
wget http://www.netgull.com/gcc/releases/gcc-4.8.2/gcc-4.8.2.tar.bz2
wget http://ftp.vim.org/ftp/gnu/gmp/gmp-4.3.2.tar.bz2
wget http://www.multiprecision.org/mpc/download/mpc-0.8.1.tar.gz
wget http://www.mpfr.org/mpfr-2.4.2/mpfr-2.4.2.tar.bz2
wget ftp://gcc.gnu.org/pub/gcc/infrastructure/cloog-0.18.1.tar.gz
wget ftp://gcc.gnu.org/pub/gcc/infrastructure/isl-0.12.2.tar.bz2

## untar gcc
tar xf gcc-4.8.2.tar.bz2
## untar prereqs
# gmp
tar xf gmp-4.3.2.tar.bz2
mv gmp-4.3.2 gcc-4.8.2/gmp
# mpc
tar xf mpc-0.8.1.tar.gz
mv mpc-0.8.1 gcc-4.8.2/mpc
# mpfr
tar xf mpfr-2.4.2.tar.bz2
mv mpfr-2.4.2 gcc-4.8.2/mpfr
# cloog
tar xf cloog-0.18.1.tar.gz
mv cloog-0.18.1 gcc-4.8.2/cloog
# isl
tar xf isl-0.12.2.tar.bz2
mv isl-0.12.2 gcc-4.8.2/isl

# build gcc
rm -rf gcc
mkdir gcc
cd gcc
../gcc-4.8.2/configure --prefix=${INSTALL_PREFIX} --enable-languages=c,c++ --disable-multilib
make -j ${CPUS} ${VERBOSE}

# install it
${SUDO} rm -rf ${INSTALL_PREFIX}
${SUDO} make install
```

## Buid clang

下面的脚本利用上面安装的gcc 4.8.2编译安装clang到目录：`~/.local/share/clang/trunk`。同样也需要配置一下PATH和LD_LIBRARY_PATH环境变量。

```bash
#!/bin/bash
set -exv

## modify the following as needed for your environment
# location where clang should be installed
INSTALL_PREFIX=${HOME}/.local/share/clang/trunk
# location of gcc used to build clang
HOST_GCC=${HOME}/.local/share/gcc/4.8.2
# number of cores
CPUS=$(nproc)
# uncomment following to get verbose output from make
#VERBOSE=VERBOSE=1
# uncomment following if you need to sudo in order to do the install
#SUDO=sudo

#
# gets clang tree from svn into ./llvm
# params (e.g., -r) can be specified on command line
#
rm -rf llvm
## get everything
# llvm
svn co $* http://llvm.org/svn/llvm-project/llvm/trunk llvm
# clang
cd llvm/tools
svn co $* http://llvm.org/svn/llvm-project/cfe/trunk clang
cd -
# extra
cd llvm/tools/clang/tools
svn co $* http://llvm.org/svn/llvm-project/clang-tools-extra/trunk extra
cd -
# compiler-rt
cd llvm/projects
svn co $* http://llvm.org/svn/llvm-project/compiler-rt/trunk compiler-rt
cd -

## build clang w/gcc installed in non-standard location
rm -rf clang
mkdir -p clang
cd clang
cmake -DCMAKE_C_COMPILER=${HOST_GCC}/bin/gcc -DCMAKE_CXX_COMPILER=${HOST_GCC}/bin/g++ -DGCC_INSTALL_PREFIX=${HOST_GCC} -DCMAKE_CXX_LINK_FLAGS="-L${HOST_GCC}/lib64 -Wl,-rpath,${HOST_GCC}/lib64" -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} -DLLVM_ENABLE_ASSERTIONS=ON -DCMAKE_BUILD_TYPE="Release" -DLLVM_TARGETS_TO_BUILD="X86" ../llvm
make -j ${CPUS} ${VERBOSE}

# install it
${SUDO} rm -rf ${INSTALL_PREFIX}
${SUDO} make install
```

## Reference

[^1]: One reason is that gcc 4.9.0 can’t compile libc++, the llvm version of the C++ standard library – see http://lists.llvm.org/pipermail/cfe-dev/2014-April/036650.html for more detail.
