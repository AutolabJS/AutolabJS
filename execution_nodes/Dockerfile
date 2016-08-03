FROM ubuntu:14.04.4

COPY . /execution_nodes
RUN sudo apt-get update
RUN sudo apt-get install --force-yes -y nodejs
RUN sudo apt-get install --force-yes -y npm
RUN sudo apt-get install --force-yes -y software-properties-common 
RUN cd execution_nodes; npm install
RUN sudo apt-add-repository -y  ppa:webupd8team/java
RUN sudo apt-get update
RUN sudo apt-get install --force-yes -y git
RUN echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | sudo debconf-set-selections; sudo apt-get install --force-yes -y oracle-java8-installer 
