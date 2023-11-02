variable "main_cidr_block" {
    description = "The main cidr block for the VPC"
    type        = string
}
variable "default_region" {
    description = "The default region of the infrastructure"
    type        = string
}
variable "instance_ami" {
    description = "The ami of Ubuntu OS"
    type        = string
}