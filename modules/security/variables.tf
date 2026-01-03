# =========================================================================
# SECURITY MODULE - VARIABLES.TF
# =========================================================================

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where security groups will be created"
  type        = string
}

variable "alb_port" {
  description = "Port for the Application Load Balancer"
  type        = number
  default     = 80
}

variable "app_port" {
  description = "Port for the application"
  type        = number
  default     = 3000
}

variable "ssh_port" {
  description = "Port for SSH access"
  type        = number
  default     = 22
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}
