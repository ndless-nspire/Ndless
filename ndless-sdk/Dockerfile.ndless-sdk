# Ndless SDK

FROM ndless/arm-gcc

ADD . /ndless-sdk
RUN chown -R ndless:ndless /ndless-sdk

ENV PATH /ndless-sdk/bin:$PATH

# (Re-)build the SDK
RUN cd /ndless-sdk && make clean && make

