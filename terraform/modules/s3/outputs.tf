output "my_bucket_name" {
  value = aws_s3_bucket.my_bucket.bucket
}
output "my_bucket_id" {
  value = aws_s3_bucket.my_bucket.id
}
output "my_bucket_arn" {
  value = aws_s3_bucket.my_bucket.arn
}