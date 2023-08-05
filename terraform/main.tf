terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
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


// ==== LAMBDA + S3 RESOURCES ==== //

resource "aws_iam_role" "lambda_role" {
 name   = "terraform_aws_lambda_role"
 assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "lambda_policy" {
  name = "terraform_aws_lambda_policy"
  path = "/"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

// We give lambda another policy to write to the s3 bucket
resource "aws_iam_policy" "lambda_write_to_s3_policy" {
  name = "s3-write-policy"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:PutObjectAcl"
            ],
            "Resource": [
                "arn:aws:s3:::${aws_s3_bucket.my_bucket.bucket}",
                "arn:aws:s3:::${aws_s3_bucket.my_bucket.bucket}/*"
            ]
        }
    ]
}
EOF
}

// Now we create the S3 bucket
resource "aws_s3_bucket" "my_bucket" {
  bucket = "s3-flask-bucket" 
}



# Attach the policy to the role 
resource "aws_iam_role_policy_attachment" "attach_policy_to_role" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

// Attach the s3 write to the existing role
resource "aws_iam_role_policy_attachment" "lambda_s3_attachment" {
  policy_arn = aws_iam_policy.lambda_write_to_s3_policy.arn
  role       = aws_iam_role.lambda_role.name
}


# Generate .zip file to be uploaded to the lambda function 
data "archive_file" "zip_python_code" {
  type          = "zip"
  source_dir    = "${path.module}/python"
  output_path   = "${path.module}/python/hello_world.zip"
}


# Finally, create the lambda function itself
resource "aws_lambda_function" "lambda_function" {
  filename            = "${path.module}/python/hello_world.zip"
  function_name       = "lambda_flask"
  role                = aws_iam_role.lambda_role.arn
  handler             = "hello_world.lambda_handler"
  runtime             = "python3.10"
  architectures       = ["x86_64"]
  source_code_hash    = "${data.archive_file.zip_python_code.output_base64sha256}"
  depends_on          = [aws_iam_role_policy_attachment.attach_policy_to_role, aws_iam_role_policy_attachment.lambda_s3_attachment]
  timeout             = 60

  # https://github.com/keithrozario/Klayers/tree/master/deployments/python3.10
  layers = [
    "arn:aws:lambda:eu-central-1:770693421928:layer:Klayers-p310-Pillow:3"
  ]
}


