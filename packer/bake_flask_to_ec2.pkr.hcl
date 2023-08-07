variable "aws_access_key" {
  type = string
}

variable "aws_secret_key" {
  type = string
}

variable "aws_region" {
  type = string
}


source "amazon-ebs" "flask_app_ami" {
  ami_name      = "flask-app-{{timestamp}}"
  instance_type = "t2.micro"
  region        = "eu-central-1"

  source_ami_filter {
    filters = {
      "virtualization-type" = "hvm"
      "image-id"            = "ami-0e00e602389e469a3"
      "root-device-type"    = "ebs"
    }
    most_recent = true
    owners      = ["amazon"]
  }

  ssh_username = "ec2-user"
  ssh_pty      = true
}

build {
  name    = "Flask App Packer Build"
  sources = ["source.amazon-ebs.flask_app_ami"]

  provisioner "shell" {
    inline = [
      "sudo yum update -y",  
      "sudo yum install -y python3 python3-pip", 
      "sudo yum install -y nginx",
      "pip3 install virtualenv"
    ]
  }

  provisioner "file" {
    source      = "../flask-app" 
    destination = "/home/ec2-user/app/"
  }

  // We need to create the venv, source into it and install packages 
  provisioner "shell" {
    inline = [
      "cd /home/ec2-user/app",
      "virtualenv --python python3.9.16 venv",
      "source ./venv/bin/activate",
      "pip3 install Flask",
      "pip3 install gunicorn",
      "pip3 install boto3"
    ]
  }

  provisioner "file" {
    content     = <<-EOT
[Unit]
Description=Gunicorn service for Flask app
After=network.target

[Service]
User=ec2-user
WorkingDirectory=/home/ec2-user/app
ExecStartPre=cd /home/ec2-user/app
ExecStart=/home/ec2-user/app/venv/bin/gunicorn -b localhost:8000 -w 3 app:app
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOT
    destination = "/home/ec2-user/gunicorn.service"
  }

  provisioner "file" {
    content     = <<-EOT
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
EOT
    destination = "/home/ec2-user/nginx.conf"
  }

  provisioner "shell" {
    inline = [
      "sudo mv /home/ec2-user/gunicorn.service /etc/systemd/system/gunicorn.service",
      "sudo mv /home/ec2-user/nginx.conf /etc/nginx/conf.d/nginx.conf",

      "sudo systemctl start gunicorn",
      "sudo systemctl enable gunicorn",

      "sudo systemctl start nginx",
      "sudo systemctl enable nginx",

      "aws configure set aws_access_key_id '${var.aws_access_key}'",
      "aws configure set aws_secret_access_key '${var.aws_secret_key}'",
      "aws configure set region '${var.aws_region}'"
    ]
  }
}