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
  primary_zone        = data.aws_availability_zones.available.names[0]
  base_ami            = "base ami for ubuntu for eu-central-1"
  instance_type       = "t2.micro"
  ec2_profile_name    = "default or other instance profile"
}

module "netorking" {
  source              = "./modules/networking"
  internal_dn         = local.internal_dn
  main_cidr_block     = var.main_cidr_block
  primary_zone        = local.primary_zone
}
 
module "ec2" {
  source              = "./modules/ec2"
  main_private_subnet = module.netorking.main_private_subnet
  base_ami            = local.base_ami
  instance_type       = local.instance_type
  ec2_profile_name    = local.ec2_profile_name
}