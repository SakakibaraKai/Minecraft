provider "aws" {
  region = "us-west-2"
}

data "aws_security_group" "existing" {
  name = "MineCraft"
}

resource "aws_security_group" "minecraft" {
  count       = length(data.aws_security_group.existing) == 0 ? 1 : 0
  name        = "MineCraft"
  description = "Security group for Minecraft server"
  vpc_id      = "vpc-03d794f6b57f97142"

  ingress {
    from_port   = 25565
    to_port     = 25565
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "minecraft" {
  ami           = "ami-05a6dba9ac2da60cb"
  instance_type = "t4g.small"
  key_name      = "lab6"
  availability_zone = "us-west-2a"
  subnet_id     = "subnet-0dc899575612c8714"
  vpc_security_group_ids = length(data.aws_security_group.existing) == 0 ? 
                            [aws_security_group.minecraft[0].id] : 
                            [data.aws_security_group.existing.id]

  lifecycle {
    prevent_destroy = true  
  }
}

