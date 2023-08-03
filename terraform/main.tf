terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}


# Private variables defined in terraform.tfvars
variable "region" {
  type = string
}

variable "access_key" {
  type = string
}

variable "secret_key" {
  type = string
}

provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}


# Getting the VPC + the security groups associated with it
data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "subnets" {
  vpc_id = data.aws_vpc.default.id
}

locals {
  default_vpc_id = data.aws_vpc.default.id
  default_vpc_subnet_ids = tolist(data.aws_subnet_ids.subnets.ids)
}


// ==== START OF SGs ==== //

// SG for ALB
resource "aws_security_group" "alb_SG" {
  name   = "alb-flask-SG"
  description = "ALB SG allows ingress from anywhere."


  vpc_id = local.default_vpc_id

  // ingress from ANY source 
  ingress {
    from_port   = "80"
    to_port     = "80"
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terraform_ALB_SG"
  }
}

# SG for EC2
resource "aws_security_group" "EC2_flask_SG" {
  name_prefix = "EC2-flask-SG"
  description = "Security group for EC2 instance running Flask app."

  vpc_id = local.default_vpc_id

  // Allow incoming HTTP traffic from the ALB security group
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    security_groups = [aws_security_group.alb_SG.id]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terraform_EC2_SG"
  }
}

// ==== END OF SGs ==== //

// ==== CREATING THE ALB RESOURCE ==== //
resource "aws_lb" "alb_flask" {
  name               = "alb-flask"
  internal           = false
  load_balancer_type = "application"

  security_groups    = [aws_security_group.alb_SG.id]
  subnets            = local.default_vpc_subnet_ids

  tags = {
    Name = "terraform_ALB"
  }
}

// Now we define the EC2 to be the target group of the ALB
resource "aws_lb_target_group" "alb_flask_target_group" {
  name        = "alb-flask-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = local.default_vpc_id
  target_type = "instance"

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 10
    path                = "/"
    port                = "traffic-port"
  }
}

resource "aws_lb_listener" "alb_flask_listener" {
  load_balancer_arn = aws_lb.alb_flask.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_flask_target_group.arn
  }
}


// We define the EC2 
resource "aws_instance" "EC2_flask" {
  ami             = "ami-07ce6ac5ac8a0ee6f" 
  instance_type   = "t2.micro"
  subnet_id       = local.default_vpc_subnet_ids[0]

  security_groups = [aws_security_group.EC2_flask_SG.id]

  tags = {
    Name = "terraform_EC2"
  }
}

// Register EC2 instance with the target group
resource "aws_lb_target_group_attachment" "attachment" {
  target_group_arn = aws_lb_target_group.alb_flask_target_group.arn
  target_id        = aws_instance.EC2_flask.id
  port             = 80
}
