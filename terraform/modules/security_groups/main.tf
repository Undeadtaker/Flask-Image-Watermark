resource "aws_default_security_group" "default" {
  vpc_id = var.main_vpc

  ingress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = true
  }
}

// SG for ALB
resource "aws_security_group" "alb_SG" {
  name   = "alb-flask-SG"
  description = "ALB SG allows ingress from anywhere."


  vpc_id = var.main_vpc

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

  vpc_id = var.main_vpc

  // Allow incoming HTTP traffic from the ALB security group
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    security_groups = [aws_security_group.alb_SG.id]
  }

  ingress {
    from_port   = 443
    to_port     = 443
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

resource "aws_security_group" "EC2_observe_SG" {
  name_prefix = "EC2-observe-SG"
  description = "Security group for EC2 instance running monitoring servers."

  vpc_id = var.main_vpc

  # Inbound rule for Node Exporter (e.g., port 9100)
  ingress {
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    security_groups = [aws_security_group.EC2_flask_SG.id]
  }

  # Inbound rule for cAdvisor (e.g., port 8080)
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    security_groups = [aws_security_group.EC2_flask_SG.id]
  }

  # Inbound rule for Promtail (e.g., syslog port)
  ingress {
    from_port   = 514
    to_port     = 514
    protocol    = "tcp"
    security_groups = [aws_security_group.EC2_flask_SG.id]
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