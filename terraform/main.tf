provider "aws" {
  region = "us-west-2"
}

resource "aws_instance" "minecraft" {
  ami           = "ami-01cd4de4363ab6ee8"
  instance_type = "t3.small"

  tags = {
    Name = "MinecraftServer"
  }
}
