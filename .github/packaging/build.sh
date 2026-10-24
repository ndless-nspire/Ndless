#!/bin/sh
set -eu

root="$(pwd)"
export PATH="$root/ndless-sdk/bin:$root/ndless-sdk/toolchain/install/bin:$PATH"
export PARALLEL="${PARALLEL:--j4}"

if [ "${TOOLCHAIN_CACHE_HIT:-false}" != true ]; then
	# Toolchain host sources use C17 semantics with GCC 15.
	# Release C++ flags reduce host debug data and package size.
	(cd ndless-sdk/toolchain && CFLAGS="${CFLAGS:--O2 -std=gnu17}" \
		CXXFLAGS="${CXXFLAGS:--O2}" sh ./build_toolchain.sh)
	for component in ndless-sdk/toolchain/download/*; do
		[ -d "$component" ] || continue
		dir="ndless-sdk/toolchain/install/share/licenses/$(basename "$component")"
		mkdir -p "$dir"
		for file in "$component"/COPYING* "$component"/COPYRIGHT* "$component"/newlib/COPYING*; do
			[ -f "$file" ] || continue
			cp "$file" "$dir/"
		done
	done
fi

make "$PARALLEL"
