FROM ubuntu:14.04.4

COPY . /load_balancer

RUN sudo apt-get update
RUN sudo apt-get install -y nodejs
RUN sudo apt-get install -y npm
RUN cd load_balancer; npm install
RUN sudo apt-get update
RUN sudo apt-get install -y git
