#!/bin/sh
# Written by Uwe Hermann <uwe@hermann-uwe.de>, released as public domain.
# Edited by Travis Wiens ( http://blog.nutaksas.com/2009/05/installing-gnuarm-arm-toolchain-on.html )
# Edited by Lionel Debroux for newer gcc/binutils/newlib/gdb versions and nspire-gcc.
# Edited by Legimet for elf2flt and newer gcc/binutils/newlib/gdb versions.
# Edited by Levak to update elf2flt url
# Edited by Fabian Vogt to use the local (patched) version of elf2flt, newlib, GDB with python

# IMPORTANT NOTE: in order to compile GCC 4.8, you need the GMP (libgmp-dev), MPFR (libmpfr-dev) and MPC (libmpc-dev) development libraries.
# 	For example, if you have installed them yourself in $PREFIX, you'll have to add --with-gmp=$PREFIX --with-mpfr=$PREFIX --with-mpc=$PREFIX.
# IMPORTANT NOTE #2: GDB needs some python includes for python support. 
# 	If you don't have them and you don't need python support, remove the --with-python from OPTIONS_GDB below.
 
TARGET=arm-none-eabi
PREFIX=$HOME/ndless-toolchain # or the directory where the toolchain should be installed in
PARALLEL="-j8" # or "-j<number of build jobs>"
 
BINUTILS=binutils-2.24 # http://www.gnu.org/software/binutils/
GCC=gcc-4.8.2 # http://gcc.gnu.org/
# newlib-2.0.1 is broken for ARM :-(
NEWLIB=newlib-2.0.0 # http://sourceware.org/newlib/
GDB=gdb-7.7 # http://www.gnu.org/software/gdb/

# For newlib
export CFLAGS_FOR_TARGET="-DMALLOC_PROVIDED -mcpu=arm926ej-s -fpic -mlong-calls"
export CXXFLAGS_FOR_TARGET="-DMALLOC_PROVIDED -mcpu=arm926ej-s -fpic -mlong-calls"
export PATH=$PREFIX/bin:$PATH

OPTIONS_BINUTILS="--target=$TARGET --prefix=$PREFIX --enable-interwork --enable-multilib --with-system-zlib --with-gnu-as --with-gnu-ld --disable-nls --with-float=soft --disable-werror"
OPTIONS_GCC="--target=$TARGET --prefix=$PREFIX --enable-interwork --enable-multilib --enable-languages="c,c++" --with-system-zlib --with-newlib --with-headers=../$NEWLIB/newlib/libc/include --disable-shared --with-gnu-as --with-gnu-ld --with-float=soft --disable-werror"
OPTIONS_NEWLIB="--target=$TARGET --prefix=$PREFIX --enable-interwork --enable-multilib --with-gnu-as --with-gnu-ld --disable-newlib-may-supply-syscalls --disable-newlib-supplied-syscalls --with-float=soft --disable-werror --disable-nls --enable-newlib-io-float"
OPTIONS_GDB="--target=$TARGET --prefix=$PREFIX --enable-interwork --enable-multilib --disable-werror --with-python"
OPTIONS_ELF2FLT="--target=$TARGET --prefix=$PREFIX -with-libbfd=../build-binutils/bfd/libbfd.a --with-libiberty=../build-binutils/libiberty/libiberty.a --with-bfd-include-dir=../build-binutils/bfd --with-binutils-include-dir=../$BINUTILS/include"

echo "Building and installing to '$PREFIX'..."

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"

mkdir -p "$PREFIX"
cd "$PREFIX"
mkdir -p download build-binutils build

# Section 0: prerequisites
echo 'int main() {return 0;}' > test.c
error=0
if ! gcc -lgmp test.c -o test; then error=1; echo 'GMP (libgmp-dev) dependency seems to be missing!'; fi
if ! gcc -lmpfr test.c -o test; then error=1; echo 'MPFR (libmpfr-dev) dependency seems to be missing!'; fi
if ! gcc -lmpc test.c -o test; then error=1; echo 'MPC (libmpc-dev) dependency seems to be missing!'; fi
if ! gcc -lz test.c -o test; then error=1; echo 'zlib (zlib1g-dev) dependency seems to be missing!'; fi
if ! gcc -ltermcap test.c -o test; then error=1; echo 'termcap (libtinfo-dev) dependency seems to be missing!'; fi
if ! gcc -lpython2.7 test.c -o test; then error=1; echo 'libpython2.7 (python2.7-dev) dependency seems to be missing!'; fi
rm test test.c
if ! makeinfo -h > /dev/null; then error=1; echo 'makeinfo (textinfo) dependency seems to be missing!'; fi
[ $error -eq 1 ] && exit 1


if [ ! -f .downloaded ]; then
	wget -c http://ftp.gnu.org/gnu/binutils/$BINUTILS.tar.bz2 -O download/binutils.tar.bz2 && tar xvjf download/binutils.tar.bz2 && \
	wget -c ftp://ftp.gnu.org/gnu/gcc/$GCC/$GCC.tar.bz2 -O download/gcc.tar.bz2 && tar xvjf download/gcc.tar.bz2 && \
	wget -c ftp://ftp.gnu.org/gnu/gdb/$GDB.tar.bz2 -O download/gdb.tar.bz2 && tar xvjf download/gdb.tar.bz2 && \
	wget -c ftp://sourceware.org/pub/newlib/$NEWLIB.tar.gz -O download/newlib.tar.gz && tar xvzf download/newlib.tar.gz && \
	touch .downloaded
fi
 
# Section 1: GNU Binutils.
echo "Building Binutils..."
[ -f .built_binutils ] || (cd build-binutils && rm -rf * && ../$BINUTILS/configure $OPTIONS_BINUTILS && make $PARALLEL all && make install && cd .. && touch .built_binutils) || exit 1;
 
# Section 2: GCC, step 1.
echo "Building GCC (step 1)..."
[ -f .built_gcc_step1 ] || (cd build && rm -rf * && ../$GCC/configure $OPTIONS_GCC && make $PARALLEL all-gcc && make install-gcc && cd .. && rm -rf build/* && touch .built_gcc_step1) || exit 1;
 
# Section 3: Newlib.
echo "Building Newlib..."
[ -f .built_newlib ] || (cd build && rm -rf * && ../$NEWLIB/configure $OPTIONS_NEWLIB && make $PARALLEL && make install && cd .. && rm -rf build/* && touch .built_newlib) || exit 1;
 
# Section 4: GCC, step 2. Yes, this is necessary.
echo "Building GCC (step 2)..."
[ -f .built_gcc_step2 ] || (cd build && ../$GCC/configure $OPTIONS_GCC && make $PARALLEL && make install && cd .. && rm -rf build/* && touch .built_gcc_step2) || exit 1
 
# Section 5: GDB.
echo "Building GDB..."
[ -f .built_gdb ] || (cd build && rm -rf * && ../$GDB/configure $OPTIONS_GDB && make $PARALLEL && make install && cd .. && rm -rf build/* && touch .built_gdb) || exit 1;
 
# Section 6: elf2flt.
echo "Building elf2flt..."
[ -f .built_elf2flt ] || (cd build && rm -rf * && "$SCRIPTPATH"/elf2flt/configure $OPTIONS_ELF2FLT && make $PARALLEL && make install && cd .. && rm -rf build/* && touch .built_elf2flt) || exit 1;

echo "Done!"
echo "Don't forget to add '$PREFIX/bin' to your \$PATH along with Ndless-SDK/ndless/bin."

