FROM ubuntu:16.04

COPY . /load_balancer

RUN  apt-get update && apt-get install --force-yes -y nodejs npm git
RUN cd load_balancer; npm install

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]
