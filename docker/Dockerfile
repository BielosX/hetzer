FROM debian:jessie-slim

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 0C49F3730359A14518585931BC711F9BA15703C6
RUN echo "deb http://repo.mongodb.org/apt/debian jessie/mongodb-org/3.4 main" | tee /etc/apt/sources.list.d/mongodb-org-3.4.list
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install --assume-yes apt-utils
RUN apt-get install -y mongodb-org
RUN mkdir -p /data/db

EXPOSE 27017
COPY mongod.conf /etc/mongod.conf
ENTRYPOINT ["/usr/bin/mongod", "--config", "/etc/mongod.conf"]
