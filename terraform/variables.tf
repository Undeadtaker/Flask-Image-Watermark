variable access_key {
    type        = string
}
variable secret_key {
    type        = string
}
variable "main_cidr_block" {
    description = "The main cidr block for the VPC"
    type        = string
}
variable "default_region" {
    description = "The default region of the infrastructure"
    type        = string
}
variable "base_ami" {
    description = "The ami of Ubuntu OS"
    type        = string
}
variable "instance_type" {
    type        = string
}