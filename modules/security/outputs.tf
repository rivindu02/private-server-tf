# =========================================================================
# SECURITY MODULE - OUTPUTS.TF
# =========================================================================

output "alb_sg_id" {
  description = "ID of the ALB security group"
  value       = aws_security_group.alb.id
}

output "bastion_sg_id" {
  description = "ID of the Bastion security group"
  value       = aws_security_group.bastion.id
}

output "app_sg_id" {
  description = "ID of the application security group"
  value       = aws_security_group.app.id
}
