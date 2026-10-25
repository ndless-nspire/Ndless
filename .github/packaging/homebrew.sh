#!/bin/sh
set -eu

: "${PACKAGE_VERSION:?PACKAGE_VERSION is required}"
: "${GITHUB_SHA:?GITHUB_SHA is required}"
: "${GITHUB_WORKSPACE:?GITHUB_WORKSPACE is required}"
: "${RUNNER_TEMP:?RUNNER_TEMP is required}"
export HOMEBREW_NO_AUTO_UPDATE=1

work=$(mktemp -d "$RUNNER_TEMP/ndless-homebrew.XXXXXX")
trap 'git config --global --fixed-value --unset-all include.path "$work/gitconfig" || true; rm -rf "$work"' EXIT HUP INT TERM
out="$RUNNER_TEMP/packages"
mkdir -p "$out"
source=https://github.com/ndless-nspire/Ndless.git

# Use the checked-out Git sources.
export BREW_GIT_CONFIG="$work/gitconfig"
git config --file "$BREW_GIT_CONFIG" protocol.file.allow always
git config --file "$BREW_GIT_CONFIG" "url.file://$GITHUB_WORKSPACE/.insteadOf" "$source"
# shellcheck disable=SC2016
git submodule --quiet foreach --recursive \
    'git config --file "$BREW_GIT_CONFIG" "url.file://$PWD/.insteadOf" "$(git config --get remote.origin.url)"'
git config --global --add include.path "$BREW_GIT_CONFIG"

brew install --overwrite python@3.13
brew tap --custom-remote ndless/ci "$source"
formula="$(brew --repository ndless/ci)/Formula/ndless-sdk.rb"
ruby - "$GITHUB_WORKSPACE/Formula/ndless-sdk.rb" "$formula" "$PACKAGE_VERSION" "$GITHUB_SHA" <<'RUBY'
source, path, version, revision = ARGV
formula = File.read(source)
formula.sub!(/^  head .*$/, <<SOURCE.chomp) or abort "head source not found"
  url "https://github.com/ndless-nspire/Ndless.git", using: :git,
      revision: "#{revision}"
  version "#{version}"
SOURCE
File.write(path, formula)
RUBY

brew install --verbose --build-bottle ndless/ci/ndless-sdk
cp "$formula" "$out/ndless-sdk.rb"
(cd "$out" && brew bottle --json ndless/ci/ndless-sdk)
