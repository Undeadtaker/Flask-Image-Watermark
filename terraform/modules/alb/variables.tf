variable "main_vpc" {
  type = string
}
variable "main_public_subnet" {
  type = string
}
variable "flask_instance_ids" {
  type = list()
}
variable "main_flask_certificate" {
  type = string
}

