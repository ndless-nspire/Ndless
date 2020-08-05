#!/bin/sh
# Written by Uwe Hermann <uwe@hermann-uwe.de>, released as public domain.
# Edited by Travis Wiens ( http://blog.nutaksas.com/2009/05/installing-gnuarm-arm-toolchain-on.html )
# Edited by Lionel Debroux for newer gcc/binutils/newlib/gdb versions and nspire-gcc.
# Edited by Legimet for elf2flt and newer gcc/binutils/newlib/gdb versions.
# Edited by Levak to update elf2flt url
# Edited by Fabian Vogt to use the local (patched) version of elf2flt, newlib, GDB with python
# Edited by FrostyPenguin to support overriding $PARALLEL

# IMPORTANT NOTE: in order to compile GCC, you need the GMP (libgmp-dev), MPFR (libmpfr-dev) and MPC (libmpc-dev) development libraries.
# 	For example, if you have installed them yourself in ${PREFIX}, you'll have to add --with-gmp=${PREFIX} --with-mpfr=${PREFIX} --with-mpc=${PREFIX}.
# IMPORTANT NOTE #2: GDB needs some python includes for python support.
# 	If you don't have them and you don't need python support, remove the --with-python from OPTIONS_GDB below.

set -eu

TARGET=arm-none-eabi
PREFIX="${PWD}/install" # or the directory where the toolchain should be installed in
PARALLEL="${PARALLEL--j4}" # or "-j<number of build jobs>"
PYTHON="${PYTHON-$(which python3 2>/dev/null)}" # or the full path to the python interpreter

BINUTILS=binutils-2.34 # https://www.gnu.org/software/binutils/
GCC=gcc-10.1.0 # https://gcc.gnu.org/
NEWLIB=newlib-3.0.0 # https://sourceware.org/newlib/
GDB=gdb-9.1 # https://www.gnu.org/software/gdb/

# For newlib
export CFLAGS_FOR_TARGET="-DHAVE_RENAME -DMALLOC_PROVIDED -DABORT_PROVIDED -DNO_FORK -mcpu=arm926ej-s -ffunction-sections -Ofast -funroll-loops"
export CXXFLAGS_FOR_TARGET="-DHAVE_RENAME -DMALLOC_PROVIDED -DABORT_PROVIDED -DNO_FORK -mcpu=arm926ej-s -ffunction-sections -Ofast -funroll-loops"
export PATH="${PREFIX}/bin:${PATH}"

OPTIONS_BINUTILS="--target=${TARGET} --prefix=${PREFIX} --enable-interwork --enable-multilib --with-system-zlib --with-gnu-as --with-gnu-ld --disable-nls --with-float=soft --disable-werror"
OPTIONS_GCC="--target=${TARGET} --prefix=${PREFIX} --enable-interwork --enable-multilib --enable-languages=c,c++ --with-system-zlib --with-newlib --disable-threads --disable-tls --disable-shared --with-gnu-as --with-gnu-ld --with-float=soft --disable-werror --disable-libstdcxx-verbose"
OPTIONS_NEWLIB="--target=${TARGET} --prefix=${PREFIX} --enable-interwork --enable-multilib --with-gnu-as --with-gnu-ld --disable-newlib-may-supply-syscalls --disable-newlib-supplied-syscalls --with-float=soft --disable-werror --disable-nls --enable-newlib-io-float"
OPTIONS_GDB="--target=${TARGET} --prefix=${PREFIX} --enable-interwork --enable-multilib --disable-werror"

if [ -n "${PYTHON}" ]; then
	OPTIONS_GDB="${OPTIONS_GDB} --with-python=${PYTHON}"
fi

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
if [ -n "${PYTHON}" ] && [ ! -x "${PYTHON}-config" ]; then error=1; echo "${PYTHON}-config (python3-devel/python3-dev) dependency seems to be missing!"; fi
rm -f test test.c
[ $error -eq 1 ] && exit 1

mkdir -p build download

downloadAndExtract() {
	url="$1"
	target="download/$(basename "${url}")"
	if ! wget -c "$url" -O "${target}"; then
		rm -f "${target}"
		return 1
	fi
	echo "Extracting $(basename "${url}")..."
	tar -xf "${target}" -C download
}

# Section 1: GNU Binutils.
if [ "$(cat .built_binutils 2>/dev/null)" != "${BINUTILS}" ]; then
	if [ ! -d "download/${BINUTILS}" ]; then
		echo "Downloading Binutils..."
		rm -rf download/binutils*
		downloadAndExtract https://ftp.gnu.org/gnu/binutils/${BINUTILS}.tar.bz2
	fi

	echo "Building Binutils..."
	rm -rf build; mkdir build
	cd build
		../download/${BINUTILS}/configure ${OPTIONS_BINUTILS}
		make $PARALLEL all
		make install
	cd ..
	echo -n "${BINUTILS}" > .built_binutils
fi

# Section 2: GCC, step 1.
if [ "$(cat .built_gcc_step1 2>/dev/null)" != "${GCC}" ]; then
	if [ ! -d "download/${GCC}" ]; then
		echo "Downloading GCC..."
		rm -rf download/gcc*
		downloadAndExtract https://ftp.gnu.org/gnu/gcc/${GCC}/${GCC}.tar.xz
	fi

	# gcc creates a sysroot with some includes from newlib.
	# While this shouldn't be necessary, it doesn't load the libc provided limits.h
	# from the gcc generated include-fixed/limits.h otherwise...
	if [ ! -d "download/${NEWLIB}" ]; then
		echo "Downloading Newlib..."
		rm -rf download/newlib*
		downloadAndExtract https://sourceware.org/pub/newlib/${NEWLIB}.tar.gz
	fi

	echo "Building GCC (step 1)..."
	rm -rf build; mkdir build
	cd build
		../download/${GCC}/configure ${OPTIONS_GCC} --with-headers=../download/${NEWLIB}/newlib/libc/include
		make $PARALLEL all-gcc
		make install-gcc
	cd ..
	# Some of the headers copied from newlib are autogenerated, but newlib didn't
	# build yet so it's just dummy content.
	rm "${PREFIX}/arm-none-eabi/sys-include/newlib.h"
	rm "${PREFIX}/arm-none-eabi/sys-include/_newlib_version.h"
	echo -n "${GCC}" > .built_gcc_step1
fi

# Section 3: Newlib.
if [ "$(cat .built_newlib 2>/dev/null)" != "${NEWLIB}" ]; then
	if [ ! -d "download/${NEWLIB}" ]; then
		echo "Downloading Newlib..."
		rm -rf download/newlib*
		downloadAndExtract https://sourceware.org/pub/newlib/${NEWLIB}.tar.gz
	fi

	echo "Building Newlib..."
	rm -rf build; mkdir build
	cd build
		../download/${NEWLIB}/configure ${OPTIONS_NEWLIB}
		make $PARALLEL
		make install
	cd ..
	echo -n "${NEWLIB}" > .built_newlib
fi

# Section 4: GCC, step 2. Yes, this is necessary.
if [ "$(cat .built_gcc_step2 2>/dev/null)" != "${GCC}" ]; then
	if [ ! -d "download/${GCC}" ]; then
		echo "Downloading GCC..."
		rm -rf download/gcc*
		downloadAndExtract https://ftp.gnu.org/gnu/gcc/${GCC}/${GCC}.tar.xz
	fi

	echo "Building GCC (step 2)..."
	rm -rf build; mkdir build
	cd build
		../download/${GCC}/configure ${OPTIONS_GCC}
		make $PARALLEL
		make install
	cd ..
	echo -n "${GCC}" > .built_gcc_step2
fi

# Section 5: GDB.
if [ "$(cat .built_gdb 2>/dev/null)" != "${GDB}" ]; then
	if [ ! -d "download/${GDB}" ]; then
		echo "Downloading GDB..."
		rm -rf download/gdb*
		downloadAndExtract https://ftp.gnu.org/gnu/gdb/${GDB}.tar.xz
	fi

	echo "Building GDB..."
	rm -rf build; mkdir build
	cd build
		../download/${GDB}/configure ${OPTIONS_GDB}
		make $PARALLEL
		make install
	cd ..
	echo -n "${GDB}" > .built_gdb
fi

echo "Cleaning up..."
rm -rf build
[ -d download ] && echo "You can delete the download/ directory to save some space."

echo "Done!"
echo "Don't forget to add '${PREFIX}/bin:$(dirname ${SCRIPTPATH})/bin' to your \$PATH."
