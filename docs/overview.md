# Repository overview

Updated 2026-11-16.

Ndless provides the loader and development tools that let third-party programs
run on supported TI-Nspire calculators. The repository builds both the SDK on
the development computer and the installers and resources transferred to the
calculator. Installation instructions for each supported model and OS version
are in the [README](../README.md#quick-guide).

## Components

| Component | Responsibility |
| --- | --- |
| [`ndless/src/resources/`](../ndless/src/resources/) | Executable loading, OS hooks, syscall support, persistence support, and the resources payload |
| [`ndless/src/installer-*`](../ndless/src/) | Installation entry points for specific OS families |
| [`ndless/src/persistent-6.4/`](../ndless/src/persistent-6.4/) | Persistent installation for the supported newer OS versions |
| [`ndless/src/tools/`](../ndless/src/tools/) | Tools used to build and maintain the calculator-side components |
| [`ndless-sdk/include/`](../ndless-sdk/include/) | Headers used by calculator applications |
| [`ndless-sdk/libndls/`](../ndless-sdk/libndls/) and [`libsyscalls/`](../ndless-sdk/libsyscalls/) | Ndless application support and interfaces to OS functions |
| [`ndless-sdk/system/`](../ndless-sdk/system/) | Startup assembly and linker script |
| [`ndless-sdk/bin/`](../ndless-sdk/bin/) | Compiler and linker wrappers, including `nspire-gcc` |
| [`ndless-sdk/tools/`](../ndless-sdk/tools/) | Tools including `genzehn`, `luna`, and the Zehn loader |
| [`ndless-sdk/samples/`](../ndless-sdk/samples/) | Example applications and their build rules |
| [`ndless-sdk/thirdparty/`](../ndless-sdk/thirdparty/) | Third-party libraries used by the SDK |

The [root Makefile](../Makefile) builds the SDK before Ndless. Within the SDK,
the library, tool, system, and sample targets have their own dependency order.
The [Ndless source Makefile](../ndless/src/Makefile) builds its tools before the
resources and installers. Use these Makefiles to preserve that ordering.

## Build from source

The [CI build workflow](../.github/workflows/main.yml) provides the Ubuntu
build recipe. Building the compiler toolchain downloads and compiles its
dependencies, so this is a longer setup step than compiling an application
with an installed SDK.

1. Initialize the submodules with `git submodule update --init --recursive`
   from the repository root. The [submodule configuration](../.gitmodules)
   includes nspire-io, zlib, FreeType, and luna; the root Makefile checks for
   their source files before building.
2. Install the host build dependencies. The toolchain script requires GMP,
   MPFR, MPC, zlib, and curl, and checks for Python development support when
   Python is enabled. The SDK tools also use Boost program_options. The
   [Debian packaging recipe](../.github/packaging/debian.sh) lists the broader
   dependency set used for an automated build.
3. From `ndless-sdk/toolchain/`, run `./build_toolchain.sh`. It installs the
   ARM toolchain under that directory's `install/` tree. Run it from that
   directory because the install prefix is based on the working directory.
4. Add the absolute paths of `ndless-sdk/toolchain/install/bin` and
   `ndless-sdk/bin` to your shell's `PATH`.
5. Return to the repository root and run `make` to build the SDK, sample
   applications, Ndless resources, and installers.
6. To create the calculator distribution, run `make dist` from the root.
   This recreates `dist/` and packages the result as `dist/ndless.zip`;
   the packaging command requires `7z`.

For application examples, inspect the Makefiles in
[`helloworld-cpp`](../ndless-sdk/samples/helloworld-cpp/) or
[`zehn`](../ndless-sdk/samples/zehn/). The SDK wrappers supply target flags and
paths to the Ndless headers and startup code. The
[developer guide](https://ndlessly.wordpress.com/ndless-for-developers/)
covers application development, and the
[Docker README](../ndless-sdk/README-Docker.md) describes the SDK image build.

## Build automation and verification

The repository has two GitHub Actions workflows:

- [CI](../.github/workflows/main.yml) checks out submodules, builds or restores
  the ARM toolchain, builds the repository on Ubuntu, and uploads a calculator
  distribution archive.
- [SDK packages](../.github/workflows/packages.yml) builds Linux packages for
  Debian, Fedora, and Alpine on x86_64 and aarch64, plus macOS packages through
  Homebrew and MacPorts. The package scripts live in
  [`.github/packaging/`](../.github/packaging/).

A successful host build establishes that the selected sources compile and
package. Testing installer behavior, persistence, and application execution
also requires a supported calculator and OS. Build logs alone do not establish
that those paths work on hardware.

## Distribution and licensing

The calculator distribution contains installers, `ndless_resources.tns`,
sample applications, and persistent installers in their own directory. Use the
README's instructions to choose the files for the exact model and OS version.

Most of the repository uses the
[Mozilla Public License 1.1](../Mozilla-Public-License-v1.1.html).
Components with their own license files retain those terms; check them before
redistributing SDK libraries or bundled dependencies.
