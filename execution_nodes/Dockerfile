FROM ubuntu:14.04.4

COPY . /execution_nodes

RUN sudo apt-get update
RUN sudo apt-get install -y nodejs
RUN sudo apt-get install -y npm
RUN cd execution_nodes; npm install
RUN sudo apt-get update
RUN sudo apt-get install -y git
RUN sudo apt-get install -y default-jdk
