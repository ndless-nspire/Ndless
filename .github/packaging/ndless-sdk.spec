# Preserve ARM archives and objects for the target toolchain.
%global debug_package %{nil}
%global __os_install_post %{nil}

# Restrict dependency metadata to host binaries; SDK libraries stay private.
%global __requires_exclude_from ^(/usr/share/ndless/|/usr/lib/ndless-sdk/(include|lib|system|tools/zehn_loader)/|/usr/lib/ndless-sdk/toolchain/install/(arm-none-eabi|lib/gcc/arm-none-eabi)/)
%global __provides_exclude_from ^/usr/lib/ndless-sdk/

Name:           ndless-sdk
Version:        %{ndless_version}
Release:        1%{?dist}
Summary:        Ndless SDK and ARM toolchain for TI-Nspire calculators
License:        MPL-1.1 and bundled licenses
URL:            https://github.com/ndless-nspire/Ndless
Requires:       bash, make, coreutils, findutils, which, python3, util-linux
Requires:       gmp, mpfr, libmpc, zlib, libstdc++, boost-program-options

%description
Ndless SDK, ARM C/C++ toolchain and development tools for TI-Nspire calculators,
including calculator installers and example programs. Bundled component licenses
are installed in /usr/share/doc/ndless-sdk.

%install
mkdir -p %{buildroot}
cp -a /package-root/. %{buildroot}/

%files
/usr/lib/ndless-sdk
%{_bindir}/nspire-tools
%{_bindir}/nspire-gcc
%{_bindir}/nspire-g++
%{_bindir}/nspire-as
%{_bindir}/nspire-ld
%{_bindir}/genzehn
%{_bindir}/make-prg
%{_bindir}/luna
/usr/share/ndless
%doc /usr/share/doc/ndless-sdk
