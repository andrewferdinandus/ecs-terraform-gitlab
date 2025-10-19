variable "project_name" {
  description = "ECS Project"
  type        = string
  default     = "ecs_project"
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


variable "public_subnets_cidr" {
    description = "Public Subents' CIDRs for Each AZ"
    type = list(string)
    default = ["10.0.1.0/24", "10.0.2.0/24"]
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

# ECR Repository URL (will be passed by pipeline)
variable "ecr_repo_url" {
  description = "ECR repository URL to pull image from"
  type        = string
  default     = null
}

# Docker image tag (also passed by pipeline)
variable "image_tag" {
  description = "Image tag for the Docker image in ECR"
  type        = string
  default     = "latest"
}

# Vertical scaling (manual or from pipeline)
variable "service_size" {
  description = "Service size to control CPU and memory (small, medium, large)"
  type        = string
  default     = "small"
}

