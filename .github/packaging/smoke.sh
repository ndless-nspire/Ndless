#!/bin/sh
set -eu

if [ "$(id -u)" = 0 ]; then
	dir="$(mktemp -d)"
	trap 'rm -rf "$dir"' EXIT HUP INT TERM
	chmod 777 "$dir"
	script="$(realpath "$0")"
	su -s /bin/sh nobody -c "cd '$dir' && HOME='$dir' PATH=/usr/bin:/bin sh '$script'"
	exit 0
fi

toolchain="$(nspire-tools _toolchainpath)"
"$toolchain/arm-none-eabi-gdb" -q -nx -batch -ex 'python print("GDB Python OK")'

mkdir c cpp
cd c
nspire-tools new smoke-c
cat > main.c <<'EOF'
#include <stdio.h>
#include <libndls.h>
int main(void) {
	printf("Ndless C package smoke\n");
	return 0;
}
EOF
make
"$toolchain/arm-none-eabi-readelf" -h smoke-c.elf | grep 'Machine:.*ARM'

cd ../cpp
nspire-tools new smoke-cpp
cat > main.cpp <<'EOF'
#include <vector>
#include <cstdio>
int main() {
	std::vector<int> values(3, 42);
	std::printf("Ndless C++ package smoke: %d\n", values.at(1));
	return 0;
}
EOF
make LD=nspire-g++ 'ZEHNFLAGS=--name smoke-cpp --compress'
"$toolchain/arm-none-eabi-readelf" -h smoke-cpp.elf | grep 'Machine:.*ARM'

cd ..
printf 'print("Ndless Lua package smoke")\n' > smoke.lua
luna smoke.lua smoke-lua.tns
python3 - <<'PY'
with open("smoke-lua.tns", "rb") as f:
    assert f.read(6) == b"*TIMLP", "invalid Lua TNS document"
PY
printf 'Installed SDK smoke passed\n'
