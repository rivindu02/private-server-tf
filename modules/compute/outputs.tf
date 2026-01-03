# =========================================================================
# COMPUTE MODULE - OUTPUTS.TF
# =========================================================================

output "bastion_id" {
  description = "ID of the Bastion instance"
  value       = aws_instance.bastion.id
}

output "bastion_public_ip" {
  description = "Public IP of the Bastion instance"
  value       = aws_instance.bastion.public_ip
}

output "bastion_private_ip" {
  description = "Private IP of the Bastion instance"
  value       = aws_instance.bastion.private_ip
}

output "app_server_id" {
  description = "ID of the application server instance"
  value       = aws_instance.app_server.id
}

output "app_server_private_ip" {
  description = "Private IP of the application server instance"
  value       = aws_instance.app_server.private_ip
}
