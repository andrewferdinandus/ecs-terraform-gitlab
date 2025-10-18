resource "aws_vpc" "main_vpc" {
  cidr_block           = var.vpc_cidr_block.default
  enable_dns_hostnames = var.main_vpc.enable_dns_hostnames
  enable_dns_support   = var.main_vpc.enable_dns_support

  tags = {
    Name = var.main_vpc.name
  }
}