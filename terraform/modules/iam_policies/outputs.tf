# ec2_observe_profile
# ec2_flask_profile

output "ec2_flask_profile" {
  value = aws_iam_instance_profile.ec2_flask_profile.name
}
