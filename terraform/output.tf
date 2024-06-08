output "minecraft_server_public_ip" {
  value = aws_network_interface.minecraft_server.public_ip
}

data "aws_ecs_task" "minecraft_server" {
  cluster = aws_ecs_cluster.minecraft_server.id
  task_id = aws_ecs_service.minecraft_server.id
}

data "aws_network_interface" "minecraft_server" {
  for_each = toset(data.aws_ecs_task.minecraft_server.network_interfaces)
  id       = each.value
}
