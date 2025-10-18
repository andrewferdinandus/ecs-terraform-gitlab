#ECS Security Group
resource "aws_security_group" "ecs_sec_group" {
  name        = var.ecs_sec_group.name
  vpc_id      = aws_vpc.main_vpc.id
  description = var.ecs_sec_group.description

  ingress {
    description = "Allow HTTP Traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]


  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    name = var.ecs_sec_group.name
  }
}
