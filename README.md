# Flask Image Watermark
 

![Untitled Diagram (4)](https://github.com/Undeadtaker/Flask-Image-Watermark/assets/61665341/247fb45c-1bf2-4496-ac72-59bd0e8ffc55)


# Installation
### 1) Install terraform and packer

In order to run this you have to have both terraform and packer installed. You can find the downloads here:
> Terraform:
> https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli
>
> Packer
> https://developer.hashicorp.com/packer/tutorials/docker-get-started/get-started-install-cli


### 2) Setup AWS credentials

Once you have installed the above mentioned software, you need to create or get a user which has administrator (or other) 
permissions to provision infrastructure. You will then create a key pair for this account in order to feed it into terraform
and packer.

To feed the keys into terraform you will naviagate to the terraform folder and create a file called "terraform.tfvars". Inside of it
set these values.

`region = "{the region where you want the infrastructure to be provisioned}"` 

`access_key = "{account access key}"`

`secret_key = "{account secret key}"` 

The file terraform.tfvars should look something like this (NOTE: these are dummy values)

`region = "eu-central-1"` 

`access_key = "AKIAdummyAccessKey1234567890"` 

`secret_key = "2T4Vm3Qz6K8G1oB9cP5D7HrIjLqOzR8S1X6Y4bG7"` 

To feed the keys into packer you will naviagate to the packer folder and create a file called "variables.pkrvars.hcl". Do the same
as you have done for terraform.tfvars. 

### 3) Provision infrastructure
Before we can provision infrastructure, we need to bake the ec2 instance to create a custom AMI. To do this, open up a shell 
or command prompt and navigate to the packer folder. Here, you will write 

`packer build -var-file="variables.pkrvars.hcl" .` 

Wait for the process to finish. Then finally to provision the infrastructure and set everything up, open up a command shell and navigate to the terraform folder and write 

`terraform apply -auto-approve`. 

This will provision all the infrastructure in the background. Wait for the process to finish. Open up your aws console and find load balancers. 
Copy the dns name of the load balancer and paste the URL into your browser. 

# Usage
Upload an image and press submit. This will call the Lambda function to process the uploaded image and add a watermark to it and save it to S3. 
Once the image was uploaded, in your url append a /list_images to the url to see the uploaded images. 

So if the URL of the load balancer is
`http://alb-flask-1219196293.eu-central-1.elb.amazonaws.com`
to list images you would do:
`http://alb-flask-1219196293.eu-central-1.elb.amazonaws.com/list_images`

Here you can see the uploaded images. 

# Thank you for taking an interest in my project! :) 




