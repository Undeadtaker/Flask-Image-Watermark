variable "base_dn" {
  type = string
}
variable "main_vpc" {
  type = string
}
variable "region" {
  type = string
}
variable "flask_private_ips" {
  type = list()
}
variable "observe_private_ip" {
  type = string
}
variable "deployment_name" {
  type = string
}