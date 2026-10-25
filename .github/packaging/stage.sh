#!/bin/sh
set -eu

dest="${1:?Usage: stage.sh DESTDIR [PREFIX]}${2:-/usr}"
sdk="$dest/lib/ndless-sdk"
mkdir -p "$sdk/tools/zehn_loader" "$sdk/tools/luna" "$sdk/toolchain" \
	"$dest/bin" "$dest/share/ndless/samples" \
	"$dest/share/ndless/persistent" "$dest/share/doc/ndless-sdk"

cp -a ndless-sdk/bin ndless-sdk/include ndless-sdk/lib ndless-sdk/system "$sdk/"
cp -a ndless-sdk/toolchain/install "$sdk/toolchain/"
cp ndless-sdk/tools/zehn_loader/zehn_loader*.tns "$sdk/tools/zehn_loader/"
cp ndless-sdk/tools/luna/luna "$sdk/tools/luna/"
find "$sdk" -name .gitignore -delete

for cmd in nspire-tools nspire-gcc nspire-g++ nspire-as nspire-ld genzehn make-prg; do
	chmod 755 "$sdk/bin/$cmd"
	ln -s "../lib/ndless-sdk/bin/$cmd" "$dest/bin/$cmd"
done
chmod 755 "$sdk/bin/arm-none-eabi-ld.gold" "$sdk/tools/luna/luna"
ln -s ../lib/ndless-sdk/tools/luna/luna "$dest/bin/luna"

cp ndless/calcbin/*.tns "$dest/share/ndless/"
mv "$dest"/share/ndless/persistent_*.tns "$dest/share/ndless/persistent/"
rm -f "$dest"/share/ndless/downgradefix_3.9*.tns \
	"$dest/share/ndless/ndless_installer_3.9.0_classic.tns"
cp ndless-sdk/samples/*/*.tns "$dest/share/ndless/samples/"
rm -f "$dest/share/ndless/samples/freetype_demo.tns"
cp README.md Mozilla-Public-License-v1.1.html "$dest/share/doc/ndless-sdk/"
# Keep component license paths.
find ndless-sdk -path ndless-sdk/toolchain -prune -o \
	-type f \( -iname 'license*' -o -iname 'copying*' \) -exec sh -c '
		dest=$1; shift
		for file do
			mkdir -p "$dest/$(dirname "$file")"
			cp "$file" "$dest/$file"
		done
	' sh "$dest/share/doc/ndless-sdk" {} +
