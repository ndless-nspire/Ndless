#!/bin/sh
set -eu

case "${1:-}" in
build)
	: "${PACKAGE_VERSION:?PACKAGE_VERSION is required}"
	apk add --no-cache alpine-sdk bash coreutils which git curl bzip2 xz \
		patch tar gmp-dev mpfr-dev mpc1-dev zlib-dev python3-dev boost-dev \
		texinfo flex bison linux-headers php84 ncurses-dev xxd

	sh .github/packaging/build.sh
	sh .github/packaging/stage.sh /package-root

	arch=$(apk --print-arch)
	work=$(mktemp -d)
	trap 'rm -rf "$work"' EXIT
	export ABUILD_USERDIR="$work/keys"
	export PACKAGER="Ndless CI <ndless-sdk-$arch@ndless.invalid>"
	abuild-keygen -a -n
	cp "$ABUILD_USERDIR"/*.rsa.pub /etc/apk/keys/

	mkdir -p "$work/ndless/ndless-sdk" /out
	cp .github/packaging/APKBUILD "$work/ndless/ndless-sdk/APKBUILD"
	# -F runs abuild directly in this isolated root container.
	abuild -F -C "$work/ndless/ndless-sdk" -P "$work/packages" -r
	cp "$work/packages/ndless/$arch/ndless-sdk-$PACKAGE_VERSION-r0.apk" \
		"/out/ndless-sdk-$PACKAGE_VERSION-r0.$arch.apk"
	cp "$ABUILD_USERDIR"/*.rsa.pub /out/
	;;
test)
	arch=$(apk --print-arch)
	cp /out/*.rsa.pub /etc/apk/keys/
	apk add --no-cache /out/ndless-sdk-*."$arch".apk
	sh "$(dirname "$0")/smoke.sh"
	;;
*)
	echo "Usage: $0 {build|test}" >&2
	exit 1
	;;
esac
