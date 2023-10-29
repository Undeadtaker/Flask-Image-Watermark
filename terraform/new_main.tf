terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0.0"
    }
  }
}

locals = {
  internal_dn = "placeholder"

  // The whole infrastructure is created in the first availability zone 
  primary_zone = data.aws_availability_zones.available.names[0]
}

module "netorking" {
  source          = "./modules/networking"
  internal_dn     = local.internal_dn
  main_cidr_block = var.main_cidr_block
  primary_zone    = local.primary_zone
}

