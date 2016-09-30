FROM ubuntu:14.04.4

COPY . /load_balancer

RUN sudo apt-get update && sudo apt-get install --force-yes -y nodejs npm git
RUN cd load_balancer; npm install

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]
