variable "project_name" {
  description = "ECS Project"
  type        = string
  default     = "ECS_CICD_Project"
}


variable "region" {
  default = "us-east-1"
}

variable "main_vpc" {
  type = object({
    name                 = string
    enable_dns_hostnames = bool
    enable_dns_support   = bool

  })
  default = {
    name                 = "Multi Tier VPC"
    enable_dns_hostnames = true
    enable_dns_support   = true
  }
}

variable "vpc_cidr_block" {
  description = "VPC CIDR"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "Public Subnet CIDRs (one per AZ)"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "azs" {
  description = "Availability Zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "ecs_sec_group" {
  type = object({
    name        = string
    description = string

  })
  default = {
    name        = "ECS SG"
    description = "ECS Security Group"
  }
}


