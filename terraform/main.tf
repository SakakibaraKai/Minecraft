provider "aws" {
  region = "us-west-2"
}

data "aws_security_group" "existing" {
  name = "MineCraft"
}

resource "aws_security_group" "minecraft" {
  count       = length(data.aws_security_group.existing) == 0 ? 1 : 0
  name        = "Minecraft_Security_Group1"
  description = "Security group for minecraft server"

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
  key_name      = "labweek6key"

  tags = {
    Name = "minecraft_server"
  }
  vpc_security_group_ids = length(data.aws_security_group.existing) == 0 ? [aws_security_group.minecraft[0].id] : [data.aws_security_group.existing.id]


}
