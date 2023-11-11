#!/bin/bash

# Run the Python script to get the public IP
public_ip=$(python3 ./python/get_master.py)

# Copy ansible dir
scp -i ./.ssh/test.pem -r /home/ubuntu/ansible ubuntu@$public_ip:/home/ubuntu/ansible

# SSH into the EC2 instance
if [ -n "$public_ip" ]; then
    echo "Connecting to EC2 instance with IP: $public_ip"
    ssh -i ./.ssh/test.pem ubuntu@$public_ip <<'ENDSSH'

    sudo apt update -y
    sudo apt-add-repository ppa:ansible/ansible -y
    sudo apt install ansible -y
    sudo snap install aws-cli --classic

    aws configure set aws_access_key_id "$AWS_ACCESS_KEY_ID"
    aws configure set aws_secret_access_key "$AWS_ACCESS_KEY_SECRET" 
    aws configure set region "eu-central-1"  
    aws configure set output "json" 

    sudo apt install python3-pip -y
    python3 -m pip install boto3

    cd ./ansible
    ansible-galaxy install -r requirements.yml
    ansible --inventory inventory/aws_ec2.yml --extra-vars "extra-vars.yml" all -m ping

ENDSSH
else
    echo "Failed to retrieve EC2 instance public IP."
fi