FROM ubuntu:bionic-20220801
#FROM ubuntu:bionic
# focal

ARG version

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y gnupg software-properties-common

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 8AA7AF1F1091A5FD
RUN add-apt-repository 'deb [arch=amd64] http://repo.sawtooth.me/ubuntu/chime/stable bionic universe'

# add-apt-repository ppa:deadsnakes/ppa &&
RUN apt update && apt -y install python3.6 && update-alternatives --install /usr/bin/python python /usr/bin/python3.6 1 && update-alternatives --set python /usr/bin/python3.6

RUN apt install -y python3-cchardet python3-secp256k1 python3-lmdb

RUN apt install -y apt-transport-https aptitude autoconf automake build-essential ca-certificates cmake curl git golang-go gradle htop iptraf iputils-ping jq libcurl4-openssl-dev libprotobuf-dev libssl-dev libtool libxml2-dev libltdl-dev libtool lvm2 lshw maven mlocate nano net-tools netcat ocaml openjdk-8-jdk openjdk-8-demo openjdk-8-doc openjdk-8-jre-headless openjdk-8-source openjfx pkg-config postgresql postgresql-contrib python3-pip protobuf-compiler sawtooth=$version python3-sawtooth-cli python3-sawtooth-intkey python3-sawtooth-rest-api python3-sawtooth-sdk python3-sawtooth-validator python3-sawtooth-xo speedtest-cli sshpass systemd sudo tar unzip uuid-dev wget

RUN apt install -y tzdata
RUN cp /usr/share/zoneinfo/Europe/Berlin /etc/localtime
RUN echo "Europe/Berlin" > /etc/timezone

RUN pip3 install -U protobuf==3.19.4

RUN apt install -y sawtooth-pbft-engine python3-sawtooth-poet-cli python3-sawtooth-poet-engine python3-sawtooth-poet-families sawtooth-raft-engine

RUN wget https://raw.githubusercontent.com/gdraheim/docker-systemctl-replacement/master/files/docker/systemctl.py -O /usr/local/bin/systemctl && chmod +x /usr/local/bin/systemctl

RUN curl -sL https://repos.influxdata.com/influxdb.key | apt-key add - && apt-add-repository "deb https://repos.influxdata.com/ubuntu bionic stable" && apt-get update && apt-get install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" telegraf && systemctl restart telegraf

RUN apt autoremove && apt clean

RUN chown -R root:sawtooth /etc/sawtooth

