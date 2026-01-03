# =========================================================================
# ROOT LEVEL VARIABLES
# =========================================================================

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "ap-southeast-1"
}

variable "project_name" {
  description = "Project name for resource naming and tagging"
  type        = string
  default     = "school-tf"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "prod"
}

# =========================================================================
# NETWORKING VARIABLES
# =========================================================================

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_a_cidr" {
  description = "CIDR block for public subnet in AZ A"
  type        = string
  default     = "10.0.1.0/24"
}

variable "public_subnet_b_cidr" {
  description = "CIDR block for public subnet in AZ B"
  type        = string
  default     = "10.0.3.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR block for private subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "availability_zone_a" {
  description = "First availability zone"
  type        = string
  default     = "ap-southeast-1a"
}

variable "availability_zone_b" {
  description = "Second availability zone"
  type        = string
  default     = "ap-southeast-1b"
}

# =========================================================================
# SECURITY VARIABLES
# =========================================================================

variable "alb_port" {
  description = "Port for the Application Load Balancer"
  type        = number
  default     = 80
}

variable "app_port" {
  description = "Port for the application server"
  type        = number
  default     = 3000
}

variable "ssh_port" {
  description = "Port for SSH access"
  type        = number
  default     = 22
}

# =========================================================================
# LOAD BALANCER VARIABLES
# =========================================================================

variable "health_check_path" {
  description = "Health check path for the load balancer"
  type        = string
  default     = "/"
}

variable "health_check_matcher" {
  description = "Health check status codes"
  type        = string
  default     = "200-499"
}

# =========================================================================
# COMPUTE VARIABLES
# =========================================================================

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
  description = "SSH key pair name for EC2 instances"
  type        = string
  default     = "RVK-Server2"
}

# variable "git_repository" {
#   description = "Git repository URL for the application"
#   type        = string
#   default     = "https://github.com/rivindu02/School-Management-API.git"
# }

# variable "app_environment_vars" {
#   description = "Environment variables for the application"
#   type        = map(string)
#   default = {
#     MONGO_URI = "mongodb://mongo:27017/school_db"
#     PORT      = "3000"
#   }
# }
