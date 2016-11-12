FROM ubuntu:14.04.4

COPY . /main_server

RUN sudo apt-get update && sudo apt-get install --force-yes -y nodejs npm
RUN cd main_server; npm install

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]
