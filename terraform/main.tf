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

module "security_groups" {
  source                 = "./modules/security_groups"
}

module "ec2" {
  source                 = "./modules/ec2"
  base_ami               = var.base_ami
  instance_type          = var.instance_type

  main_private_subnet    = module.netorking.main_private_subnet
  ec2_profile_name       = module.iam.ec2_flask_profile
  ec2_flask_SG           = module.security_groups.ec2_flask_SG
  ec2_observe_SG         = module.security_groups.ec2_observe_SG
}

module "s3" {
  source                 = "./modules/s3"
}

module "iam" {
  source                 = "./modules/iam"
  my_bucket              = module.s3.my_bucket
}

module "lambda" {
  source                 = "./modules/lambda"
  lambda_role            = module.iam.lambda_role
}

module "alb" {
  source                 = "./modules/alb"
  main_vpc               = module.networking.main_vpc
  alb_SG                 = module.security_groups.alb_SG
  flask_instance_ids     = module.ec2.flask_instance_ids
  main_public_subnet     = module.networking.main_public_subnet
}
