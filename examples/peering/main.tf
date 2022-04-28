# vpc peering

terraform {
  required_version = "~> 1.0"
}

provider "aws" {
  region = var.aws_region
}

# isolated vpc
module "vpc" {
  source = "../../"
  name   = join("-", [var.name, "aws"])
  tags   = var.tags
  vpc_config = {
    azs         = var.azs
    cidr        = "10.10.0.0/16"
    subnet_type = "isolated"
  }
  vpce_config = [
    {
      service             = "ec2messages"
      type                = "Interface"
      private_dns_enabled = true
    },
    {
      service             = "ssmmessages"
      type                = "Interface"
      private_dns_enabled = true
    },
    {
      service             = "ssm"
      type                = "Interface"
      private_dns_enabled = true
    },
  ]
}

# peering
resource "aws_vpc_peering_connection" "peering" {
  peer_vpc_id = module.vpc.vpc.id
  vpc_id      = module.corp.vpc.id
  auto_accept = true
}

resource "aws_route" "peer-to-corp" {
  for_each                  = module.vpc.route_tables.private
  route_table_id            = each.value
  destination_cidr_block    = module.corp.vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering.id
}

resource "aws_route" "peer-to-aws" {
  for_each                  = module.corp.route_tables.private
  route_table_id            = each.value
  destination_cidr_block    = module.vpc.vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering.id
}

# control plane network
module "corp" {
  source = "../../"
  name   = join("-", [var.name, "corp"])
  tags   = var.tags
  vpc_config = {
    azs         = var.azs
    cidr        = "10.20.0.0/16"
    subnet_type = "isolated"
    single_ngw  = true
  }
  vpce_config = [
    {
      service             = "ec2messages"
      type                = "Interface"
      private_dns_enabled = true
    },
    {
      service             = "ssmmessages"
      type                = "Interface"
      private_dns_enabled = true
    },
    {
      service             = "ssm"
      type                = "Interface"
      private_dns_enabled = true
    },
  ]

}

# ec2
module "client" {
  source  = "Young-ook/ssm/aws"
  version = "0.0.7"
  name    = var.name
  tags    = var.tags
  subnets = values(module.corp.subnets["private"])
  node_groups = [
    {
      name          = "B"
      max_size      = 1
      instance_type = "t3.large"
    },
  ]
}
