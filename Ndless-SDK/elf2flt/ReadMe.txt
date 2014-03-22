Source: http://cvs.uclinux.org/cgi-bin/cvsweb.cgi/elf2flt/

Must be built and install to YAGARTO for bFLT to work with nspire-ld-bflt.
Some patches have been applied for the Ndless SDK.

To build and install on Windows:

- Install MSYS/MinGW
- Install mingw32-lz : mingw-get install mingw32-lz
- Download and build binutils: https://github.com/tangrs/ndless-bflt-toolchain
- Build and install elf2flt:
  LIBS="-lws2_32 -lz" ./configure --target=arm-none-eabi --with-libbfd="path/to/binutils-2.21/bfd/libbfd.a" --with-libiberty="path/to/binutils-2.21/libiberty/libiberty.a" --with-bfd-include-dir="path/to//binutils-2.21/bfd" --with-binutils-include-dir="path/to/binutils-2.21/include"  --prefix="path/to/Ndless-SDK/yagarto" --enable-always-reloc-text
  make all install
