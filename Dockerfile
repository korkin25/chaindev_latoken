FROM ubuntu:trusty
USER root

ENV DEBIAN_FRONTEND noninteractive
RUN echo exit 0 > /usr/sbin/policy-rc.d
RUN apt-get update
RUN apt-get install -y nano wget gcc g++ git build-essential libtool autotools-dev automake autoconf cmake pkg-config libssl-dev libevent-dev bsdmainutils python3 libboost-all-dev software-properties-common xmlto doxygen
RUN add-apt-repository ppa:bitcoin/bitcoin
RUN apt-get update
RUN apt-get install -y apt-utils
RUN apt-get install -y libminiupnpc-dev libzmq3-dev
RUN apt-get install -y libdb4.8-dev libdb4.8++-dev

COPY . /opt
RUN mkdir -p /root/.bitcoin
COPY ./bitcoin.conf /root/.bitcoin/bitcoin.conf
WORKDIR /opt
RUN ./autogen.sh
RUN ./configure
RUN make -j 4

EXPOSE 55909 55908

