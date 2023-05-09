FROM ubuntu:bionic
# focal

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /

RUN apt update && apt install -y gnupg software-properties-common

#python-pip
RUN apt install -y apt-transport-https aptitude autoconf automake build-essential ca-certificates cmake curl expect git golang-go gradle htop iptraf iputils-ping jq libcurl4-openssl-dev libprotobuf-dev libssl-dev libtool libxml2-dev libltdl-dev libtool lvm2 lshw maven mlocate nano net-tools netcat ocaml openjdk-8-jdk openjdk-8-demo openjdk-8-doc openjdk-8-jre-headless openjdk-8-source openjfx pkg-config postgresql postgresql-contrib python3-pip python3 protobuf-compiler speedtest-cli sshpass systemd sudo tar unzip uuid-dev wget

RUN apt update && apt-get install -y software-properties-common gnupg curl &&  curl -sL https://repos.influxdata.com/influxdata-archive_compat.key | apt-key add - && apt-add-repository "deb https://repos.influxdata.com/ubuntu bionic stable" && apt-get install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" telegraf && service telegraf restart

#https://repos.influxdata.com/influxdb.key

RUN apt install -y tzdata
RUN cp /usr/share/zoneinfo/Europe/Berlin /etc/localtime
RUN echo "Europe/Berlin" > /etc/timezone

RUN apt autoremove && apt clean
