### VPC blueprint

terraform {
  required_version = "~> 1.0"
}

provider "aws" {
  region = var.aws_region
}

### network/isolated
module "vpc" {
  source  = "Young-ook/vpc/aws"
  version = "1.0.3"
  tags    = merge(var.tags, { topology = "aws" })
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
    {
      service = "s3"
      type    = "Gateway"
    },
    {
      service = "dynamodb"
      type    = "Gateway"
    },
  ]
}

### network/controller
module "corp" {
  source  = "Young-ook/vpc/aws"
  version = "1.0.3"
  tags    = merge(var.tags, { topology = "corp" })
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

### network/transit
module "tgw" {
  source     = "Young-ook/vpc/aws//modules/tgw"
  version    = "1.0.3"
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
      subnets = values(module.corp.subnets["private"])
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

### compute
module "client" {
  source  = "Young-ook/ssm/aws"
  version = "1.0.5"
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
