Deployment using Ansible
========================

1. Install dependencies by executing `./setup.sh`
2. Edit the inventory file and update the hostnames and variables
3. Run the ansible playbook by executing
   `ansible-playbook -i inventory playbook.yml -u <user_in_sudoers> --ask-sudo-pass`

Assumptions
===========

1. The SSH server on Machine 1 listens on Port 2222
