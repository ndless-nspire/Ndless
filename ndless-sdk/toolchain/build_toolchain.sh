#!/bin/sh
# Written by Uwe Hermann <uwe@hermann-uwe.de>, released as public domain.
# Edited by Travis Wiens ( http://blog.nutaksas.com/2009/05/installing-gnuarm-arm-toolchain-on.html )
# Edited by Lionel Debroux for newer gcc/binutils/newlib/gdb versions and nspire-gcc.
# Edited by Legimet for elf2flt and newer gcc/binutils/newlib/gdb versions.
# Edited by Levak to update elf2flt url
# Edited by Fabian Vogt to use the local (patched) version of elf2flt, newlib, GDB with python

# IMPORTANT NOTE: in order to compile GCC, you need the GMP (libgmp-dev), MPFR (libmpfr-dev) and MPC (libmpc-dev) development libraries.
# 	For example, if you have installed them yourself in ${PREFIX}, you'll have to add --with-gmp=${PREFIX} --with-mpfr=${PREFIX} --with-mpc=${PREFIX}.
# IMPORTANT NOTE #2: GDB needs some python includes for python support.
# 	If you don't have them and you don't need python support, remove the --with-python from OPTIONS_GDB below.

TARGET=arm-none-eabi
PREFIX="${PWD}/install" # or the directory where the toolchain should be installed in
PARALLEL="-j4" # or "-j<number of build jobs>"

BINUTILS=binutils-2.31.1 # http://www.gnu.org/software/binutils/
GCC=gcc-8.2.0 # http://gcc.gnu.org/
NEWLIB=newlib-3.0.0 # http://sourceware.org/newlib/
GDB=gdb-8.1.1 # http://www.gnu.org/software/gdb/

# For newlib
export CFLAGS_FOR_TARGET="-DHAVE_RENAME -DMALLOC_PROVIDED -DABORT_PROVIDED -DNO_FORK -mcpu=arm926ej-s -ffunction-sections -Ofast -funroll-loops"
export CXXFLAGS_FOR_TARGET="-DHAVE_RENAME -DMALLOC_PROVIDED -DABORT_PROVIDED -DNO_FORK -mcpu=arm926ej-s -ffunction-sections -Ofast -funroll-loops"
export PATH="${PREFIX}/bin:${PATH}"

OPTIONS_BINUTILS="--target=${TARGET} --prefix=${PREFIX} --enable-interwork --enable-multilib --with-system-zlib --with-gnu-as --with-gnu-ld --disable-nls --with-float=soft --disable-werror"
OPTIONS_GCC="--target=${TARGET} --prefix=${PREFIX} --enable-interwork --enable-multilib --enable-languages="c,c++" --with-system-zlib --with-newlib --with-headers=../${NEWLIB}/newlib/libc/include --disable-threads --disable-tls --disable-shared --with-gnu-as --with-gnu-ld --with-float=soft --disable-werror --disable-libstdcxx-verbose"
OPTIONS_NEWLIB="--target=${TARGET} --prefix=${PREFIX} --enable-interwork --enable-multilib --with-gnu-as --with-gnu-ld --disable-newlib-may-supply-syscalls --disable-newlib-supplied-syscalls --with-float=soft --disable-werror --disable-nls --enable-newlib-io-float"
OPTIONS_GDB="--target=${TARGET} --prefix=${PREFIX} --enable-interwork --enable-multilib --disable-werror --with-python"

# When building gcc with clang, the maximum amount of nested brackets has to be increased
if (gcc -v 2>&1 | grep clang > /dev/null); then
    export CXXFLAGS="-fbracket-depth=512 -O2"
fi

echo "Building and installing to '${PREFIX}'..."

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"

mkdir -p "${PREFIX}"

# Section 0: prerequisites
echo 'int main() {return 0;}' > test.c
error=0
if ! gcc -lgmp       test.c -o test; then error=1; echo 'GMP (gmp-devel/libgmp-dev) dependency seems to be missing!'; fi
if ! gcc -lmpfr      test.c -o test; then error=1; echo 'MPFR (mpfr-devel/libmpfr-dev) dependency seems to be missing!'; fi
if ! gcc -lmpc       test.c -o test; then error=1; echo 'MPC (mpc-devel/libmpc-dev) dependency seems to be missing!'; fi
if ! gcc -lz         test.c -o test; then error=1; echo 'zlib (zlib-devel/zlib1g-dev) dependency seems to be missing!'; fi
if ! gcc -lpython2.7 test.c -o test; then error=1; echo 'libpython2.7 (python-devel/python2.7-dev) dependency seems to be missing!'; fi
rm -f test test.c
[ $error -eq 1 ] && exit 1

mkdir -p build download

if [ ! -f .downloaded ]; then
	wget -c http://ftp.gnu.org/gnu/binutils/${BINUTILS}.tar.bz2 -O download/${BINUTILS}.tar.bz2 && tar xvjf download/${BINUTILS}.tar.bz2 && \
	wget -c ftp://ftp.gnu.org/gnu/gcc/${GCC}/${GCC}.tar.xz      -O download/${GCC}.tar.xz       && tar xvJf download/${GCC}.tar.xz && \
	wget -c ftp://sourceware.org/pub/newlib/${NEWLIB}.tar.gz    -O download/${NEWLIB}.tar.gz    && tar xvzf download/${NEWLIB}.tar.gz && \
	wget -c ftp://ftp.gnu.org/gnu/gdb/${GDB}.tar.xz             -O download/${GDB}.tar.xz       && tar xvJf download/${GDB}.tar.xz && \
	touch .downloaded
	if [ $? -ne 0 ]; then
		echo "Download failed!"
		exit 1
	fi
fi

# Section 1: GNU Binutils.
echo "Building Binutils..."
[ -f .built_binutils ] || (cd build && rm -rf ./* && ../${BINUTILS}/configure ${OPTIONS_BINUTILS} && make $PARALLEL all && make install && cd .. && rm -rf build/* && touch .built_binutils) || exit 1;

# Section 2: GCC, step 1.
echo "Building GCC (step 1)..."
[ -f .built_gcc_step1 ] || (cd build && rm -rf ./* && ../${GCC}/configure ${OPTIONS_GCC} && make $PARALLEL all-gcc && make install-gcc && cd .. && rm -rf build/* && touch .built_gcc_step1) || exit 1;

# Section 3: Newlib.
echo "Building Newlib..."
[ -f .built_newlib ] || (cd build && rm -rf ./* && ../${NEWLIB}/configure ${OPTIONS_NEWLIB} && make $PARALLEL && make install && cd .. && rm -rf build/* && touch .built_newlib) || exit 1;
# Workaround for newlib bug
rm -f "${PREFIX}/arm-none-eabi/sys-include/newlib.h"

# Section 4: GCC, step 2. Yes, this is necessary.
echo "Building GCC (step 2)..."
[ -f .built_gcc_step2 ] || (cd build && ../${GCC}/configure ${OPTIONS_GCC} && make $PARALLEL && make install && cd .. && rm -rf build/* && touch .built_gcc_step2) || exit 1

# Section 5: GDB.
echo "Building GDB..."
[ -f .built_gdb ] || (cd build && rm -rf ./* && ../${GDB}/configure ${OPTIONS_GDB} && make $PARALLEL && make install && cd .. && rm -rf build/* && touch .built_gdb) || exit 1;

echo "Done!"
echo "Don't forget to add '${PREFIX}/bin' to your \$PATH along with $SCRIPTPATH/../bin."
