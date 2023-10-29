variable "internal_dn" {
  description = "The private domain name for resources to talk to each other"
  type        = string
}
variable "main_cidr_block" {
  description = "The main VPC block from which we cut subnets"
  type        = string
}
variable "primary_zone" {
  description = "The first az in the region"
  type        = string
}