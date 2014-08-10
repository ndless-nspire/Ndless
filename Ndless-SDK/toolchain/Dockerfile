FROM oliviera/gcc
MAINTAINER Olivier Armand <olivier.calc@gmail.com>
# ARM GCC toolchain

# make sure the package repository is up to date
RUN apt-get update

# install the dependencies
RUN apt-get install -y libgmp-dev libmpfr-dev libmpc-dev zlib1g-dev libtinfo-dev python2.7-dev

RUN useradd -m -d /home/ndless -p ndless ndless && chsh -s /bin/bash ndless

ADD . /ndless-sdk/toolchain

# build the toolchain, cleanup and set up the PATH
RUN cd /ndless-sdk/toolchain && su ndless -c "./build_toolchain.sh && cd ~/ndless-toolchain && rm -rf binutils-2.24 gcc-4.8.2 gdb-7.7 newlib-2.0.0 download build-binutils build"

ENV PATH /home/ndless/ndless-toolchain/bin:$PATH

