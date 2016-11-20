FROM ubuntu:16.04

COPY . /main_server

RUN sudo apt-get update && sudo apt-get install --force-yes -y nodejs nodejs-legacy npm git
RUN cd main_server; npm install

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]
