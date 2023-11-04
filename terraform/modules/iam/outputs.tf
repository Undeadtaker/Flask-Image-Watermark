# ec2_observe_profile
# ec2_flask_profile

output "ec2_flask_profile" {
  value = aws_iam_instance_profile.ec2_flask_profile.name
}
output "lambda_role" {
  value = aws_iam_role.lambda_role.arn
}