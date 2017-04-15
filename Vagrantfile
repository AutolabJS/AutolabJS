# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  # Specify the base box
  config.vm.box = "ubuntu/xenial64"   # ubuntu 16.04 LTS 64-bit

  # Setup synced folder, a neat technique, but unused at present
  # can possibly be used in the future
  #config.vm.synced_folder ".", "/home/vagrant/autolab", type: "rsync"

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
    v.memory = 4096
    v.cpus = 2
    v.customize ["sharedfolder", "add", :id, "--name", "autolab", "--hostpath", "#ENV['VAGRANT_CWD']", "--automount"]
  end

  config.vm.provision "shell", inline: <<-SHELL
  # copy autolab folder into vagrant machine
  if [ ! -f /home/vagrant/autolab ]
  then
      mkdir -p /home/vagrant/autolab
  fi

  # change the default port of SSH server
  sudo sed -i 's/^Port 22/Port 2222/' /etc/ssh/sshd_config
  sudo sudo service ssh restart
  sudo usermod -a -G vboxsf ubuntu
  echo "sudo mount -t vboxsf autolab /home/vagrant/autolab" >> /home/ubuntu/.bashrc
  echo "sudo mount --bind /vagrant /home/vagrant/autolab" >> /home/ubuntu/.bashrc
  echo "mount --bind /vagrant /home/vagrant/autolab" >> /root/.bashrc
  echo "cd /home/vagrant/autolab" >>  /home/ubuntu/.bashrc
  SHELL

  # install autolab
  config.vm.provision :shell, privileged: true, path: "deploy/dev_setup/vagrant.sh"
end
