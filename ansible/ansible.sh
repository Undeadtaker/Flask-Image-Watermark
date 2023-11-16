#!/bin/bash

# ### Output the private key for instances
# terraform output pk_ansible > ./devnet_private.key
chmod 400 ../private.pem
eval `ssh-agent -s`
ssh-add ../private.pem

### Run ansible to configure the nodes
ansible-galaxy install -r requirements.yml
ansible-inventory --graph
ansible -i inventory/aws_ec2.yml --extra-vars "extra-vars.yml" all -m ping