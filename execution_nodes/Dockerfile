FROM ubuntu:14.04.4

COPY . /execution_nodes
RUN sudo apt-add-repository -y  ppa:webupd8team/java && sudo apt-get update && echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | sudo debconf-set-selections && sudo apt-get install --force-yes -y oracle-java8-installer nodejs npm software-properties-common git
RUN cd execution_nodes; npm install

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]
