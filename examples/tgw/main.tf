# Hybrid network

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
      service             = "notebook"
      type                = "Interface"
      private_dns_enabled = false
    },
    {
      service             = "sagemaker.api"
      type                = "Interface"
      private_dns_enabled = true
    },
    {
      service             = "sagemaker.runtime"
      type                = "Interface"
      private_dns_enabled = true
    },
    {
      service             = "sts"
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
    subnet_type = "private"
    single_ngw  = true
  }
}

# transit gateway
module "tgw" {
  source     = "../../modules/tgw"
  tags       = var.tags
  tgw_config = {}
  vpc_attachments = {
    vpc = {
      vpc     = module.vpc.vpc.id
      subnets = values(module.vpc.subnets["private"])
      routes = [
        {
          destination_cidr_block = "10.50.0.0/16"
        },
        {
          blackhole              = true
          destination_cidr_block = "0.0.0.0/0"
        }
      ]
    }
    corp = {
      vpc     = module.corp.vpc.id
      subnets = values(module.corp.subnets["public"])
      routes = [
        {
          destination_cidr_block = "10.40.0.0/16"
        },
        {
          blackhole              = true
          destination_cidr_block = "10.10.10.10/32"
        }
      ]
    }
  }
}

# client
module "client" {
  source      = "Young-ook/ssm/aws"
  name        = var.name
  tags        = var.tags
  subnets     = values(module.corp.subnets["public"])
  node_groups = var.client_instances
}
