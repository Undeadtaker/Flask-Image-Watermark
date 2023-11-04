output "alb_SG" {
    value = aws_security_group.alb_SG.id
}
output "ec2_flask_SG" {
    value = aws_security_group.ec2_flask_SG.id
}
output "ec2_observe_SG" {
    value = aws_security_group.ec2_observe_SG.id
}
