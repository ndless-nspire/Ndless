#!/bin/sh
set -eu

case "${1-}" in
    build)
        : "${PACKAGE_VERSION:?PACKAGE_VERSION is required}"
        dnf install -y --setopt=install_weak_deps=False \
            gcc gcc-c++ make rpm-build redhat-rpm-config binutils \
            ca-certificates git curl bzip2 xz patch tar \
            gmp-devel mpfr-devel libmpc-devel zlib-devel python3-devel \
            boost-devel texinfo flex bison php-cli bash coreutils \
            which findutils diffutils util-linux ncurses-devel

        sh .github/packaging/build.sh
        sh .github/packaging/stage.sh /package-root

        tmp=$(mktemp -d)
        trap 'rm -rf "$tmp"' EXIT HUP INT TERM
        mkdir -p "$tmp"/BUILD "$tmp"/BUILDROOT "$tmp"/RPMS \
            "$tmp"/SOURCES "$tmp"/SPECS "$tmp"/SRPMS /out
        rpmbuild -bb --define "_topdir $tmp" \
            --define "ndless_version $PACKAGE_VERSION" \
            .github/packaging/ndless-sdk.spec
        cp "$tmp"/RPMS/"$(rpm --eval '%{_arch}')"/*.rpm /out/
        ;;
    *)
        echo "usage: $0 build" >&2
        exit 1
        ;;
esac
