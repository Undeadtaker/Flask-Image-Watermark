variable "main_private_subnet" {
  description = "The id of private subnet from networking module"
  type        = string
}
variable "main_public_subnet" {
  description = "The id of the main public subnet for master bastion host"
  type        = string
}
variable "base_ami" {
  description = "The ami of ubuntu"
  type        = string
}
variable "instance_type" {
  description = "The instance type, t2.micro"
  type        = string
}
variable "ec2_flask_profile" {
  description = "The profile name"
  type        = string
}
variable "ec2_flask_SG" {
  type        = string
}
variable "ec2_observe_SG" {
  type        = string
}