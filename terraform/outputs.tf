# ---- Basics useful for debugging & docs ----
output "project_name" {
  description = "Project name used to name AWS resources"
  value       = var.project_name
}

output "region" {
  description = "AWS region deployed to"
  value       = var.region
}

output "service_size" {
  description = "Selected vertical scaling size (small|medium|large)"
  value       = var.service_size
}

# ---- Networking ----
# If your VPC resource is named differently, adjust aws_vpc.main.id
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets used by the service"
  value       = [for s in aws_subnet.public_web : s.id]
}

output "ecs_security_group_id" {
  description = "Security Group attached to ECS tasks"
  value       = aws_security_group.ecs_sec_group.id
}

# ---- ECR / Logs ----
output "ecr_repository_url" {
  description = "ECR repository URL where the image is pushed"
  value       = aws_ecr_repository.ecr_repo.repository_url
}

output "log_group_name" {
  description = "CloudWatch log group for the ECS task"
  value       = aws_cloudwatch_log_group.ecs.name
}

# ---- ECS ----
output "ecs_cluster_name" {
  description = "ECS Cluster name"
  value       = aws_ecs_cluster.ecs_cluster.name
}

output "task_definition_arn" {
  description = "Current Task Definition ARN"
  value       = aws_ecs_task_definition.ecs_task_def.arn
}

output "ecs_service_name" {
  description = "ECS Service name"
  value       = aws_ecs_service.ecs_service.name
}

