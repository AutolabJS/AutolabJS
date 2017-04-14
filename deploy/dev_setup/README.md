### Create Development Environment ###

*NOTE:* These scripts have been tested on **lubuntu 16.04 AMD64 Desktop** setup. They should work on all variants of Ubuntu 16.04 distribution.    

#### Clean Slate ####
The scripts and software in this directory help create the development environment for Autolab software. You can install the necessary software by executing _env_setup.sh_ bash shell script. If you have copies of packages like vagrant / virtualbox, please place them in _packages/_ sub-directory.

```shell
cd deploy/dev_setup
# place all the necessary deb files in "packages/" subdirectory
chmod +x env_setup.sh
sudo ./env_setup.sh
```

If you have the saved docker images of Autolab components, place them in ```JavaAutolab/docker-images``` directory.    

If you want to setup and test Autolab software, execute the Vagrant environment. Please note that the vagrant machine requires 4GB of RAM. You are advised to run the vagrant command only on a computer with at least 4 core CPU, 6GB of RAM and 20GB hard disk space.     
```shell
cd ../..    #do to the top-level directory of Autolab code base
vagrant up
```

#### Repeat Provisioning ####
Repeat Provisioning refers to a scenario of multiple vagrant provisionings. We typically want to provision a new vagrant machine after significant change in the code base. Thus repeat provisioning is needed for DevOps scenarios.
Repeat provisioning is a single vagrant command.
```shell
# go to the top-level directory of Autolab code base
vagrant up
```
