FROM ubuntu:bionic-20220801
#FROM ubuntu:bionic
# focal

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y gnupg software-properties-common

RUN apt install -y apt-transport-https aptitude autoconf automake build-essential ca-certificates cmake curl git htop iptraf iputils-ping jq libcurl4-openssl-dev libprotobuf-dev libssl-dev libtool libxml2-dev libltdl-dev libtool lvm2 lshw maven mlocate nano net-tools netcat ocaml pkg-config python3-pip python3 protobuf-compiler speedtest-cli sshpass systemd sudo tar unzip uuid-dev wget

RUN curl -sL https://repos.influxdata.com/influxdb.key | apt-key add - && apt-add-repository "deb https://repos.influxdata.com/ubuntu bionic stable" && apt-get update && apt-get install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" telegraf && service telegraf restart

RUN apt install -y tzdata
RUN cp /usr/share/zoneinfo/Europe/Berlin /etc/localtime
RUN echo "Europe/Berlin" > /etc/timezone

RUN apt autoremove && apt clean
