# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  # Specify the base box
  config.vm.box = "ubuntu/xenial64"   # ubuntu 16.04 LTS 64-bit
  config.disksize.size = '20GB'

  # copy current directory to vagrant machine
  config.vm.synced_folder ".", "/home/vagrant/autolabjs", type: "rsync"

  # port forwarding. must run ssh_local_forward.sh to get Autolab to work properly
  config.ssh.guest_port = 2222
  config.vm.network "forwarded_port", guest: 22, host: 9001, id: "git"
  config.vm.network "forwarded_port", guest: 80, host: 9002, id: "gitlab-http"
  config.vm.network "forwarded_port", guest: 443, host: 9003, id: "gitlab-https"
  config.vm.network "forwarded_port", guest: 2222, host: 2222, id: "ssh"
  config.vm.network "forwarded_port", guest: 9000, host: 9000, id: "autolab"

  # VM specific configs
  config.vm.provider "virtualbox" do |v|
    v.gui = false
    v.name = "AutolabJS-Vagrant"
    v.memory = 4096
    v.cpus = 2
  end

  config.vm.provision "shell", inline: <<-SHELL
  # change the default port of SSH server
  sudo sed -i 's/^Port 22$/Port 2222/' /etc/ssh/sshd_config
  sudo sudo service ssh restart
  echo "cd /home/vagrant/autolabjs" >>  /home/ubuntu/.bashrc
  SHELL

  # install autolab
  config.vm.provision :shell, privileged: true, path: "deploy/dev_setup/vagrant.sh"
end
