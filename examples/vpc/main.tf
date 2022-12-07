provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source      = "Young-ook/vpc/aws"
  version     = "1.0.2"
  name        = var.name
  tags        = var.tags
  vpc_config  = var.vpc_config
  vpce_config = var.vpce_config
  vgw_config  = var.vgw_config
}
