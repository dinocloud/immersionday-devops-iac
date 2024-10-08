
data "aws_availability_zones" "available" {}
data "aws_region" "current" {}

locals {
  region         = data.aws_region.current.id
  vpc_cidr       = var.vpc_cidr
  num_of_subnets = min(length(data.aws_availability_zones.available.names), 3)
  azs            = slice(data.aws_availability_zones.available.names, 0, local.num_of_subnets)

  common_name = lower("${var.customer}-infra")
  common_tags = {
    Provisioner = "terraform"
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0.0"

  name = local.common_name
  cidr = local.vpc_cidr

  azs             = local.azs
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 6, k)]
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 6, k + 10)]

  enable_nat_gateway   = true
  create_igw           = true
  enable_dns_hostnames = true
  single_nat_gateway   = true

  manage_default_network_acl    = true
  default_network_acl_tags      = { Name = "${local.common_name}-default" }
  manage_default_route_table    = true
  default_route_table_tags      = { Name = "${local.common_name}-default" }
  manage_default_security_group = true
  default_security_group_tags   = { Name = "${local.common_name}-default" }


  tags = local.common_tags

}
