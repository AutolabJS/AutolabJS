Deployment using Ansible
========================

1. Install [ansible](http://ansible.com/) on your machine. Please refer to the
   [documentation](http://docs.ansible.com/ansible/intro_installation.html#latest-releases-via-apt-ubuntu)
   for installation instructions specific to your distribution
2. Edit the inventory file and update the hostnames and variables
3. Run the ansible playbook by executing
   `ansible-playbook -i inventory playbook.yml -u <user_in_sudoers> --ask-sudo-pass`
