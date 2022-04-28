aws_region      = "us-east-1"
azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
use_default_vpc = false
name            = "vpc-peering"
tags = {
  env = "dev"
}
