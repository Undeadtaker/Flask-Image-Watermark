terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0.0"
    }
  }
}
provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}


module "netorking" {
  source                 = "./modules/networking"
  main_cidr_block        = var.main_cidr_block
  default_region         = var.default_region
}

module "ec2" {
  source                 = "./modules/ec2"
  base_ami               = var.base_ami
  instance_type          = var.instance_type
  main_private_subnet    = module.netorking.main_private_subnet
  ec2_profile_name       = module.iam.ec2_flask_profile
}

module "s3" {
  source                 = "./modules/s3"
}

module "alb" {
  source                 = "./modules/alb"
  main_vpc               = module.networking.main_vpc
  flask_instance_ids     = module.ec2.flask_instance_ids
  main_public_subnet     = module.networking.main_public_subnet
}

module "iam" {
  source                 = "./modules/iam"
  my_bucket              = module.s3.my_bucket
}