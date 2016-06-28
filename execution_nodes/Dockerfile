FROM ubuntu:14.04.4

COPY . /execution_nodes

RUN sudo apt-get update
RUN sudo apt-get install --force-yes -y nodejs
RUN sudo apt-get install --force-yes -y npm
RUN cd execution_nodes; npm install
RUN sudo apt-get update
RUN sudo apt-get install --force-yes -y git
RUN sudo apt-get install --force-yes -y default-jdk
