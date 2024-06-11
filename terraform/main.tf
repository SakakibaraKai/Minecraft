provider "aws" {
  region = "us-west-2"
}


resource "aws_security_group" "minecraft" {
  #count       = length(data.aws_security_group.existing) == 0 ? 1 : 0
  name        = "Minecraft_Security_Group1"
  description = "Security group for minecraft server"
  vpc_id      = "vpc-0015738bfc8abd367"

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
  security_groups = [aws_security_group.minecraft.name]
  associate_public_ip_address = true

  tags = {
    Name = "minecraft_server"
  }
  #vpc_id      = "vpc-0d7050b9b79c37ac1"
  #vpc_security_group_ids = length(data.aws_security_group.existing) == 0 ? [aws_security_group.minecraft[0].id] : [data.aws_security_group.existing.id]


}
