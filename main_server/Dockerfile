FROM ubuntu:16.04

RUN apt-get update
# make sure that locales package is available
RUN apt-get install --reinstall -y locales
# uncomment chosen locale to enable it's generation
RUN sed -i 's/# en_IN.UTF-8 UTF-8/en_IN.UTF-8 UTF-8/' /etc/locale.gen
# generate chosen locale
RUN locale-gen en_IN.UTF-8
# set system-wide locale settings
ENV LANG en_IN.UTF-8
ENV LANGUAGE en_IN
ENV LC_ALL en_IN.UTF-8
# verify modified configuration
RUN dpkg-reconfigure --frontend noninteractive locales

RUN apt-get update && apt-get install -y curl
RUN curl -sL https://deb.nodesource.com/setup_8.x -o nodesource_setup.sh
RUN bash nodesource_setup.sh
RUN apt-get update && apt-get install --force-yes -y nodejs build-essential git
RUN rm nodesource_setup.sh

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]
