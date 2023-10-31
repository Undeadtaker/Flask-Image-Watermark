region = "eu-central-1"
access_key = "AKIAQ6632Q3IWGXA5QCC"
secret_key = "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"


# // Create security group for the EC2 instance. It only accepts traffic from SG
# // of ALB as ingress, and egress the security group of the S3 bucket.
# resource "aws_security_group" "django-ec2_SG" {
#   name        = "django-ec2_SG"
#   description = "EC2 SG allows ingress from ALB and egress to S3."

#   vpc_id = local.default_vpc_id

#   ingress {
#     from_port = 80
#     to_port   = 80
#     protocol  = "tcp"
#     security_groups = [aws_security_group.django-alb_SG.id]
#   }
# }


# // Finally, we create the S3 bucket.
# resource "aws_s3_bucket" "django-S3" {
#   bucket = "django-s3-image-upload-bucket"
  
#   # Apply bucket policy to allow access from the EC2 instance
#   policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Principal": {
#         "AWS": "arn:aws:iam::${aws_iam_instance_profile.django-ec2_IAM_role_instance_profile.arn}"
#       },
#       "Action": "s3:*",
#       "Resource": "arn:aws:s3:::django-s3-image-upload-bucket/*"
#     }
#   ]
# }
# EOF

# }
