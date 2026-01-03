# =========================================================================
# COMPUTE MODULE - VARIABLES.TF
# =========================================================================

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "bastion_subnet_id" {
  description = "Subnet ID for the Bastion host"
  type        = string
}

variable "app_subnet_id" {
  description = "Subnet ID for the application server"
  type        = string
}

variable "bastion_sg_id" {
  description = "Security group ID for the Bastion host"
  type        = string
}

variable "app_sg_id" {
  description = "Security group ID for the application server"
  type        = string
}

variable "bastion_instance_type" {
  description = "Instance type for the Bastion host"
  type        = string
  default     = "t3.micro"
}

variable "app_instance_type" {
  description = "Instance type for the application server"
  type        = string
  default     = "t3.small"
}

variable "key_name" {
  description = "SSH key pair name"
  type        = string
}

variable "target_group_arn" {
  description = "ARN of the target group"
  type        = string
}

variable "app_port" {
  description = "Port for the application"
  type        = number
  default     = 3000
}

# variable "git_repository" {
#   description = "Git repository URL for the application"
#   type        = string
# }

# variable "app_environment_vars" {
#   description = "Environment variables for the application"
#   type        = map(string)
#   default     = {}
# }

variable "enable_detailed_monitoring" {
  description = "Enable detailed CloudWatch monitoring"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}
