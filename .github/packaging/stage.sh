#!/bin/sh
set -eu

dest="${1:?Usage: stage.sh DESTDIR}"
sdk="$dest/usr/lib/ndless-sdk"
mkdir -p "$sdk/tools/zehn_loader" "$sdk/tools/luna" "$sdk/toolchain" \
	"$dest/usr/bin" "$dest/usr/share/ndless/samples" \
	"$dest/usr/share/ndless/persistent" "$dest/usr/share/doc/ndless-sdk"

cp -a ndless-sdk/bin ndless-sdk/include ndless-sdk/lib ndless-sdk/system "$sdk/"
cp -a ndless-sdk/toolchain/install "$sdk/toolchain/"
cp ndless-sdk/tools/zehn_loader/zehn_loader*.tns "$sdk/tools/zehn_loader/"
cp ndless-sdk/tools/luna/luna "$sdk/tools/luna/"
find "$sdk" -name .gitignore -delete

for cmd in nspire-tools nspire-gcc nspire-g++ nspire-as nspire-ld genzehn make-prg; do
	chmod 755 "$sdk/bin/$cmd"
	ln -s "../lib/ndless-sdk/bin/$cmd" "$dest/usr/bin/$cmd"
done
chmod 755 "$sdk/bin/arm-none-eabi-ld.gold" "$sdk/tools/luna/luna"
ln -s ../lib/ndless-sdk/tools/luna/luna "$dest/usr/bin/luna"

cp ndless/calcbin/*.tns "$dest/usr/share/ndless/"
mv "$dest"/usr/share/ndless/persistent_*.tns "$dest/usr/share/ndless/persistent/"
rm -f "$dest"/usr/share/ndless/downgradefix_3.9*.tns \
	"$dest/usr/share/ndless/ndless_installer_3.9.0_classic.tns"
cp ndless-sdk/samples/*/*.tns "$dest/usr/share/ndless/samples/"
rm -f "$dest/usr/share/ndless/samples/freetype_demo.tns"
cp README.md Mozilla-Public-License-v1.1.html "$dest/usr/share/doc/ndless-sdk/"
# Keep component license paths.
find ndless-sdk -path ndless-sdk/toolchain -prune -o \
	-type f \( -iname 'license*' -o -iname 'copying*' \) -exec sh -c '
		dest=$1; shift
		for file do
			mkdir -p "$dest/$(dirname "$file")"
			cp "$file" "$dest/$file"
		done
	' sh "$dest/usr/share/doc/ndless-sdk" {} +
