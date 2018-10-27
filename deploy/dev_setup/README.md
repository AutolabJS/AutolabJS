### Create Development Environment ###

*NOTE:* These scripts have been tested on **Ubuntu 16.04 AMD64 Desktop** setup. They should work on all variants of Ubuntu 16.04 distributions. Please also note that the installation is bandwidth intensive and requires approximately 1.7GB of downloads from the network. However, with repeat installations, you are likely to have cached images of Ubuntu 16.04 vagrant box and all the required docker images. In that case, the download requirement goes down to approximately 300MB per install.

The virtual machine requires about 20GB of space on the disk. Please make sure that you have sufficient space is available on the hard disk.

Please read the special instructions given below for installation on other platforms.

#### Installation of Dependencies ####
The scripts and software in this directory help create the development environment for AutolabJS software. You can install the necessary software by executing _env_setup.sh_ bash shell script. If you have copies of packages like vagrant / virtualbox, please place them in _packages/_ sub-directory.

```shell
sudo su
cd deploy/dev_setup
# place all the necessary deb files in "packages/" subdirectory
chmod +x env_setup_ubuntu.sh
sudo ./env_setup.sh
```
The `env_setup_ubuntu.sh` script installs the git, vagrant and virtualbox packages into the host operating system. Please see the compatibility matrix for different operating systems.     

| **Operating System**            | **Git** | **Vagrant** | **Virtualbox** |
|---------------------------------|---------|-------------|----------------|
| Ubuntu 16.04 and its variations | 2.7.4   | 2.1.5       | 5.2.12            |
| Debian 8.3 and its variations   | 2.1.4   | 1.9.3       | 5.0.36         |

For all other operating systems, please check the instructions for installing git, vagrant and virtualbox dependencies with versions numbers greater than or equal to the ones given in the above table.

If you have the saved docker images of AutolabJS components, place them in ```AutolabJS/docker-images``` directory.    

#### Vagrant Commands ####
All the commands in this section are to be executed from the top-level directory in which `Vagrantfile` exists.    
Vagrant uses SSH to login to the provisioned virtual machine. We changed the SSH port on host machine to 2222. Thus Vagrant can not smoothly execute `vagrant ssh` and `vagrant up` operations. To bring up the host machine, execute    
```
vagrant up
```
Vagrant software downloads the virtualbox image of Ubuntu 16.04 and provisions the virtual machine.

To login to the host machine, use    
```
vagrant ssh -- -p 2222
```

To stop the AutolabJS vagrant host machine,    
```
vagrant halt
```

To start the AutolabJS vagrant host machine again,    
```
vagrant up --no-provision
```
The above command may give a warning about `Remote connection disconnect`.  If you such warnings, press `ctrl+c` to come out of the warning loop.

To delete the AutolabJS vagrant host machine completely,    
```
vagrant destroy -f
```


#### Install ####
If you want to setup and test AutolabJS software, execute the Vagrant environment. Please note that the vagrant machine requires 4GB of RAM. You are advised to run the vagrant command only on a computer with at least 4 core CPU, 6GB of RAM and 10GB of free hard disk space.     
```shell
cd ../..    #do to the top-level directory of AutolabJS code base
vagrant up  #wait for SSH connection error message, and press ctl + c
vagrant ssh -- -p 2222
sudo su
cd /home/vagrant/autolabjs/deploy/dev_setup
# If needed, modify the following inventory variables in "single_machine" inventory file to load docker images
load_docker_images=yes
docker_images_location=/home/vagrant/autolabjs/docker-images

source host_install.sh
```

**Application URLs**    
After the installation, AutolabJS would be available on the _IP-Address / hostname_ of the guest machine at the following URLs.    

| **Service**    | **URL**                        |
|----------------|--------------------------------|
| Main server    | https://IP_address:9000        |
| AutolabJS Status | https://IP_address:9000/status |
| Gitlab         | https://IP_address:9003        |

If you wish to make the Gitlab available at the standard ports of 80, 443 please complete the steps in **SSH Port Forwarding** section.    


#### Uninstall ####
To completely delete / uninstall the AutolabJS vagrant host machine, execute the following commands from AutolabJS top-level directory in the host machine.
```
vagrant destroy -f	#delete the host machine completely
#remove the SSL certificates. If these are not removed, the reinstallation will fail.
rm deploy/keys/main_server/id_rsa*
rm deploy/keys/load_balancer/id_rsa*
```



***
#### SSH Port Forwarding ####
This section is completely optional. The commands in this section make the AutolabJS available at standard HTTP(s) ports. This is only local port redirection by utilizing SSH server. To utilize local port fowarding, execute the following commands.    
```
cd deploy/dev_setup
./ssh_local_forward.sh "<user-name>"		#current username
```
