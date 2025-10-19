resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.project_name}-cluster"

  
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals { 
        type = "Service"
        identifiers = ["ecs-tasks.amazonaws.com"] 
    }
  }
}

resource "aws_iam_role" "ecs_task_exec" {
  name               = "${var.project_name}-exec-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_exec_attach" {
  role       = aws_iam_role.ecs_task_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


locals {
  size_map = {
    small  = { cpu = 256,  memory = 512  }
    medium = { cpu = 512,  memory = 1024 }
    large  = { cpu = 1024, memory = 2048 }
  }
  size  = lookup(local.size_map, var.service_size)
  image = (
  var.ecr_repo_url != null
  ? "${var.ecr_repo_url}:${var.image_tag}"
  : "${aws_ecr_repository.ecr_repo.repository_url}:${var.image_tag}"
)

}

resource "aws_ecs_task_definition" "ecs_task_def" {
  family                   = "${var.project_name}-task"
  cpu                      = local.size.cpu
  memory                   = local.size.memory
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_task_exec.arn

  container_definitions = jsonencode([{
    name      = "web"
    image     = local.image                   # built by CI and pushed to ECR
    essential = true
    portMappings = [{ containerPort = 80, hostPort = 80 }]
    environment  = [{ name = "SERVICE_SIZE", value = var.service_size }]
    logConfiguration = {
      logDriver = "awslogs",
      options = {
        awslogs-group         = aws_cloudwatch_log_group.ecs.name, 
        awslogs-region        = var.region,
        awslogs-stream-prefix = "web"
      }
    }
  }])
}

resource "aws_ecs_service" "ecs_service" {
  name            = "${var.project_name}-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.ecs_task_def.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets = [for subnet in aws_subnet.public_web : subnet.id]
    security_groups  = [aws_security_group.ecs_sec_group.id]                    
    assign_public_ip = true                                              
  }

  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200

  tags = { Name = "${var.project_name}-service" }
}
