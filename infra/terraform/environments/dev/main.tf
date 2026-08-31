module "vpc" {
  source = "../../modules/vpc"

  name                 = var.vpc_name
  cidr_block           = var.vpc_cidr_block
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  tags                 = local.common_tags
}