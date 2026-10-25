#!/bin/sh
set -eu

: "${PACKAGE_VERSION:?PACKAGE_VERSION is required}"
: "${GITHUB_SHA:?GITHUB_SHA is required}"
: "${GITHUB_WORKSPACE:?GITHUB_WORKSPACE is required}"
: "${RUNNER_TEMP:?RUNNER_TEMP is required}"

curl --fail --location --retry 3 -o "$RUNNER_TEMP/macports.pkg" \
    https://github.com/macports/macports-base/releases/download/v2.12.7/MacPorts-2.12.7-15-Sequoia.pkg
sudo installer -pkg "$RUNNER_TEMP/macports.pkg" -target /
sudo /opt/local/bin/port -v sync

work=$(mktemp -d /tmp/ndless-macports.XXXXXX)
chmod 755 "$work"
git clone --bare "$GITHUB_WORKSPACE" "$work/ndless.git"
sudo chown -R macports "$work/ndless.git"
portdir="$work/cross/ndless-sdk"
mkdir -p "$portdir" "$RUNNER_TEMP/packages"
awk -v version="$PACKAGE_VERSION" -v commit="$GITHUB_SHA" '
    $1 == "version" { $0 = "version             " version }
    $1 == "git.branch" { $0 = "git.branch          " commit }
    /^This is a rolling source port:/ {
        $0 = "This package was built from Ndless commit " commit "."
    }
    { print }
' ports/cross/ndless-sdk/Portfile > "$portdir/Portfile"

# Export an archive on APFS.
sudo /opt/local/bin/port -v -D "$portdir" archive \
    portimage_mode=archive portarchivetype=tbz2 "git.url=file://$work/ndless.git"
archive=$(/opt/local/bin/port -q location ndless-sdk)
cp "$archive" "$RUNNER_TEMP/packages/"
cp "$portdir/Portfile" "$RUNNER_TEMP/packages/Portfile"
