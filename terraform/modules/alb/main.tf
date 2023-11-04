resource "aws_lb" "flask" {
  name               = "flask-alb"
  internal           = false 
  load_balancer_type = "application"
  subnets            = [var.main_public_subnet]
  security_groups    = [var.alb_SG]
  enable_deletion_protection = false 
}

resource "aws_lb_target_group" "flask" {
  name     = "flask-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.main_vpc
  target_type = "instance"
}

resource "aws_lb_target_group_attachment" "flask" {
  count            = 2
  target_group_arn = aws_lb_target_group.flask.arn
  target_id        = element(var.flask_instance_ids, count.index)
  port             = 80
}

resource "aws_lb_listener" "flask" {
  load_balancer_arn = aws_lb.flask.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.flask.arn
  }
}

# resource "aws_lb_listener" "flask_secure" {
#   load_balancer_arn = aws_lb.flask.arn
#   port              = 443
#   protocol          = "HTTPS"
#   certificate_arn   = var.main_flask_certificate

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.flask.arn
#   }
# }