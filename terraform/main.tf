provider "aws" {
  region = "us-west-2"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name = "minecraft_vpc"
  cidr = "10.0.0.0/16"
  azs = ["us-west-2a", "us-west-2b", "us-west-2c"]
  public_subnets = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

resource "aws_ecs_cluster" "minecraft_server" {
  name = "minecraft_server"
}

resource "aws_security_group" "minecraft_server" {
  name        = "minecraft_server"
  description = "minecraft_server"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "minecraft_server"
    from_port   = 25565
    to_port     = 25565
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
}

# Define the IAM policy document
data "aws_iam_policy_document" "ecs_task_execution_policy" {
  statement {
    actions = ["ecs:RunTask"]  # Adjust permissions as needed

    resources = ["*"]  # This should be restricted to the specific ECS resources if possible
  }
}

# Attach the policy to the existing ECS execution role
resource "aws_iam_policy_attachment" "ecs_task_execution_attachment" {
  name       = "ecs-task-execution-attachment"
  roles      = ["ecs-task-execution-role"]  # Replace with the name of your existing ECS execution role
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_task_definition" "minecraft_server" {
  family                   = "minecraft-server"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "4096"
  memory                   = "8192"
  execution_role_arn       = "arn:aws:iam::123456789012:role/YourExistingEcsExecutionRole"
  container_definitions    = jsonencode([
    {
      name          = "minecraft-server"
      image         = "itzg/minecraft-server:java17-alpine"
      essential     = true
      tty           = true
      stdin_open    = true
      portMappings  = [
        {
          containerPort = 25565
          hostPort      = 25565
          protocol      = "tcp"
        }
      ]
      environment   = [
        {
          name  = "EULA"
          value = "TRUE"
        },
        {
          name  = "VERSION"
          value = "1.19.3"
        }
      ]
      mountPoints   = [
        {
          containerPath = "/data"
          sourceVolume  = "minecraft-data"
        }
      ]
    }
  ])
  volume {
    name = "minecraft-data"
  }
}

resource "aws_ecs_service" "minecraft_server" {
  name            = "minecraft_server"
  cluster         = aws_ecs_cluster.minecraft_server.id
  task_definition = aws_ecs_task_definition.minecraft_server.arn
  desired_count   = 1
  network_configuration {
    subnets          = module.vpc.public_subnets
    security_groups  = [aws_security_group.minecraft_server.id]
    assign_public_ip = true
  }
  launch_type = "FARGATE"
}

