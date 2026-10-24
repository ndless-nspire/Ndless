#!/bin/sh
set -eu

export DEBIAN_FRONTEND=noninteractive

case "${1-}" in
    build)
        : "${PACKAGE_VERSION:?PACKAGE_VERSION is required}"
        apt-get update
        apt-get install -y --no-install-recommends \
            build-essential dpkg-dev binutils ca-certificates git curl \
            bzip2 xz-utils patch tar libgmp-dev libmpfr-dev libmpc-dev \
            zlib1g-dev python3-dev libboost-program-options-dev texinfo \
            flex bison php-cli bash coreutils gnu-which libncurses-dev

        sh .github/packaging/build.sh
        sh .github/packaging/stage.sh /package-root

        tmp=$(mktemp -d)
        trap 'rm -rf "$tmp"' EXIT HUP INT TERM
        mkdir -p "$tmp/debian" /package-root/DEBIAN /out
        cat > "$tmp/debian/control" <<EOF
Source: ndless-sdk
Section: devel
Priority: optional
Maintainer: Ndless contributors <ndless@users.noreply.github.com>

Package: ndless-sdk
Architecture: any
Description: Ndless SDK and ARM toolchain for TI-Nspire calculators
EOF
        # Scan host ELF dependencies.
        deps=$(python3 - "$tmp" <<'PY'
import os
import struct
import subprocess
import sys


def elf(path):
    with open(path, "rb") as f:
        header = f.read(20)
    if len(header) < 20 or header[:4] != b"\x7fELF":
        return None
    order = "<" if header[5] == 1 else ">"
    return struct.unpack_from(order + "HH", header, 16)


host = elf("/bin/sh")[1]
files = []
for root, dirs, names in os.walk("/package-root"):
    for name in names:
        path = os.path.join(root, name)
        if os.path.islink(path):
            continue
        header = elf(path)
        if header and header[0] in (2, 3) and header[1] == host:
            files.append("-e" + path)
if not files:
    sys.exit("no host ELF files in package")
result = subprocess.check_output(
    ["dpkg-shlibdeps", "-O", *files], cwd=sys.argv[1], text=True
)
for line in result.splitlines():
    if line.startswith("shlibs:Depends="):
        print(line.removeprefix("shlibs:Depends="))
        break
else:
    sys.exit("dpkg-shlibdeps did not produce dependencies")
PY
        )
        arch=$(dpkg --print-architecture)
        size=$(du -sk /package-root/usr | cut -f1)
        cat > /package-root/DEBIAN/control <<EOF
Package: ndless-sdk
Version: ${PACKAGE_VERSION}
Section: devel
Priority: optional
Architecture: ${arch}
Maintainer: Ndless contributors <ndless@users.noreply.github.com>
Installed-Size: ${size}
Depends: bash, make, coreutils, gnu-which, python3, ${deps}
Homepage: https://github.com/ndless-nspire/Ndless
Description: Ndless SDK and ARM toolchain for TI-Nspire calculators
 Includes the ARM C/C++ toolchain, Ndless SDK, development tools,
 calculator installers and example programs.
EOF
        dpkg-deb --build --root-owner-group /package-root \
            "/out/ndless-sdk_${PACKAGE_VERSION}_${arch}.deb"
        ;;
    *)
        echo "usage: $0 build" >&2
        exit 1
        ;;
esac
