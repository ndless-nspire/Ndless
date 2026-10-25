class NdlessSdk < Formula
  desc "C and C++ SDK for TI-Nspire calculators, including the ARM toolchain"
  homepage "https://github.com/ndless-nspire/Ndless"
  license all_of: ["MPL-1.1", "GPL-3.0-or-later", "LGPL-3.0-or-later", "BSD-3-Clause", "MIT", "CPOL-1.02", :public_domain]
  head "https://github.com/ndless-nspire/Ndless.git", branch: "master"

  depends_on "bison" => :build
  depends_on "curl" => :build
  depends_on "flex" => :build
  depends_on "make" => :build
  depends_on "php" => :build
  depends_on "pkgconf" => :build
  depends_on "texinfo" => :build
  depends_on :macos
  depends_on "boost"
  depends_on "coreutils"
  depends_on "gettext"
  depends_on "gmp"
  depends_on "libmpc"
  depends_on "mpfr"
  depends_on "python@3.13"
  depends_on "xz"
  depends_on "zlib"
  depends_on "zstd"

  uses_from_macos "expat"
  uses_from_macos "ncurses"
  uses_from_macos "vim" => :build # for xxd

  # Download toolchain sources during builds.
  allow_network_access! :build

  def install
    ENV.prepend_path "PATH", Formula["make"].opt_libexec/"gnubin"
    ENV.prepend_path "PATH", Formula["coreutils"].opt_libexec/"gnubin"
    ENV.prepend_path "PATH", Formula["python@3.13"].opt_libexec/"bin"
    ENV["PYTHON"] = (Formula["python@3.13"].opt_bin/"python3.13").to_s
    ENV["PARALLEL"] = "-j#{ENV.make_jobs}"

    cd "ndless-sdk/toolchain" do
      system "sh", "./build_toolchain.sh", "--download-only"
      system "/usr/bin/patch", "-d", "download/gcc-14.2.0", "-p1",
             "-i", buildpath/".github/packaging/gcc-setlocale.patch"
    end

    system "sh", ".github/packaging/build.sh"
    stage = buildpath/"stage"
    system "sh", ".github/packaging/stage.sh", stage, prefix
    prefix.install Pathname("#{stage}#{prefix}").children

    # Resolve SDK symlinks with coreutils.
    inreplace lib/"ndless-sdk/bin/nspire-tools" do |s|
      s.gsub! "if which realpath; then", "if [ -x #{Formula["coreutils"].opt_bin}/grealpath ]; then"
      s.gsub! 'realpath "$0"', "#{Formula["coreutils"].opt_bin}/grealpath \"$0\""
    end
  end
end
