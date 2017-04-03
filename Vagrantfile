# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  # Specify the base box
  #config.vm.box = "ubuntu/trusty64"   # Ubuntu 14.04 LTS 64-bit
  config.vm.box = "ubuntu/xenial64"   # ubuntu 16.04 LTS 64-bit
  # Setup synced folder
  config.vm.synced_folder ".", "/home/vagrant/autolab"

  # change the default port of SSH server
  config.vm.provision "shell", inline: <<-SHELL
  sudo sed -i 's/^Port 22/Port 2222/' /etc/ssh/sshd_config
  sudo sudo service ssh restart
  SHELL

  # port forwarding. must run ssh_local_forward.sh to get Autolab to work properly
  config.vm.network "forwarded_port", guest: 22, host: 9001, id: "git"
  config.vm.network "forwarded_port", guest: 80, host: 9002, id: "gitlab-http"
  config.vm.network "forwarded_port", guest: 443, host: 9003, id: "gitlab-https"
  config.vm.network "forwarded_port", guest: 2222, host: 2222, id: "ssh"
  config.vm.network "forwarded_port", guest: 9000, host: 9000, id: "autolab"

  # VM specific configs
  config.vm.provider "virtualbox" do |v|
    v.gui = false
    v.name = "Autolab-Vagrant"
    v.memory = 1024
    v.cpus = 2
  end

  # install autolab
  config.vm.provision :shell, privileged: true, path: "deploy/vagrant.sh"
end
