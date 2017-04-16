#!/bin/bash
############################
# Description: Shell script to setup the development environment for Autolab
#		The script updates the OS and then installs the following software: git, virtualbox and vagrant
#		The script also updates the python2 libraries
# Author: Prasad Talasila
# Date: 06-April-2017
# Invocation:
#		$sudo ./env_setup.sh
############################
apt-get update
apt-get install -y git

# install virtualbox and its dependencies
apt-get install -y libpython2.7 libqt5core5a libqt5gui5 libqt5opengl5 libqt5printsupport5 libqt5widgets5 libqt5x11extras5 libvpx3
apt-get -f -y install
apt-get install -y gcc make linux-headers-4.4.0-59-generic linux-headers-generic libsdl1.2debian

if [ ! -f packages/virtualbox-5.1_5.1.18-114002~Ubuntu~xenial_amd64.deb ]
then
    wget -P packages/ http://download.virtualbox.org/virtualbox/5.1.18/virtualbox-5.1_5.1.18-114002~Ubuntu~xenial_amd64.deb
fi
dpkg -i packages/virtualbox-5.1_5.1.18-114002~Ubuntu~xenial_amd64.deb


pip install setuptools
apt-get install -y python-dev

# install vagrant and its dependencies
apt-get install -y ruby

if [ ! -f packages/vagrant_1.9.3_x86_64.deb ]
then
    wget  -P packages/  https://releases.hashicorp.com/vagrant/1.9.3/vagrant_1.9.3_x86_64.deb
fi
dpkg -i packages/vagrant_1.9.3_x86_64.deb
