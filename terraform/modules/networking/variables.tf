variable "main_cidr_block" {
  description = "The main VPC block from which we cut subnets"
  type        = string
}
variable "default_region" {
  description = "The default region"
  type        = string
}