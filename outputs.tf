# =========================================================================
# ROOT LEVEL OUTPUTS
# =========================================================================

output "alb_dns_name" {
  description = "The URL to access your API"
  value       = module.load_balancer.alb_dns_name
}

output "bastion_public_ip" {
  description = "SSH into this IP to reach the private network"
  value       = module.compute.bastion_public_ip
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.networking.vpc_id
}

output "app_server_private_ip" {
  description = "Private IP of the application server"
  value       = module.compute.app_server_private_ip
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = module.load_balancer.alb_arn
}

output "target_group_arn" {
  description = "ARN of the target group"
  value       = module.load_balancer.target_group_arn
}
