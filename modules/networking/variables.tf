# =========================================================================
# NETWORKING MODULE - VARIABLES.TF
# =========================================================================

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_a_cidr" {
  description = "CIDR block for public subnet in AZ A"
  type        = string
}

variable "public_subnet_b_cidr" {
  description = "CIDR block for public subnet in AZ B"
  type        = string
}

variable "private_subnet_cidr" {
  description = "CIDR block for private subnet"
  type        = string
}

variable "availability_zone_a" {
  description = "First availability zone"
  type        = string
}

variable "availability_zone_b" {
  description = "Second availability zone"
  type        = string
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}

# The type "map(string)" in Terraform represents a map (or dictionary) where the keys are strings
# and the values are also strings. It is used to define a collection of key-value pairs where both
# the key and value are of type string. This is useful for organizing and managing related data
# in a structured way.