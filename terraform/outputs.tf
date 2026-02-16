output "public_ip" {
  value = aws_instance.node.public_ip
}

output "ssh_command_readme" {
  value = "ssh -i ${var.private_key_path} ubuntu@${aws_instance.node.public_ip}"
}
