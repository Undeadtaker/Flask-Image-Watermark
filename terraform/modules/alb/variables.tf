variable "main_vpc" {
  type = string
}
variable "alb_SG" {
  type = string
}
variable "main_public_subnet" {
  type = string
}
variable "flask_instance_ids" {
  type = list(string)
}