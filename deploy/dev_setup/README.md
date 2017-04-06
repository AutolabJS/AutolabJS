### Create Development Environment ###

*NOTE:* These scripts have been tested on **lubuntu 16.04 AMD64 Desktop** setup. They should work on all variants of Ubuntu 16.04 distribution.    

The scripts and software in this directory help create the development environment for Autolab software. You can install the necessary software by executing _env_setup.sh_ bash shell script. If you have copies of packages like vagrant / virtualbox, please place them in _packages/_ sub-directory. 

```shell
# place all the necessary deb files in "packages/" subdirectory
chmod +x env_setup.sh
sudo ./env_setup.sh
```

If you want to setup and test Autolab software, execute the Vagrant environment. Please note that the vagrant machine requires 4GB of RAM. You are advised to run the vagrant command only on a computer with at least 4 core CPU, 6GB of RAM and 20GB hard disk space.     
```shell
cd ../..    #do to the top-level directory of Autolab code base
vagrant up
```

