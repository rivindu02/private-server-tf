terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    # hashicorp is a plugin that allows the infrastructure-as-code (IaC) tool Terraform to manage resources within Amazon Web Services (AWS) environments
    # This provider is essential for defining, provisioning, and managing AWS infrastructure (like EC2 instances, S3 buckets, and VPCs) using HashiCorp Configuration Language (HCL). 
  }
}

provider "aws" {
  region = var.aws_region
}

# This Terraform configuration uses the AWS provider. If the provider block 
# does not include explicit configuration details (e.g., access key, secret key, 
# or region), Terraform will rely on the AWS CLI configuration or environment 
# variables to authenticate and determine the region. Ensure that my AWS CLI 
# is properly configured with the necessary credentials and default region 
# before running this configuration.

locals {
  project_name = var.project_name
  environment  = var.environment
  tags = {
    Project     = local.project_name
    Environment = local.environment
    ManagedBy   = "Terraform"
    CreatedAt   = timestamp()
  }
}

# =========================================================================
# NETWORKING MODULE
# =========================================================================
module "networking" {
  source = "./modules/networking"

  project_name           = local.project_name
  environment            = local.environment
  vpc_cidr               = var.vpc_cidr               #cidr = classless inter-domain routing
  public_subnet_a_cidr   = var.public_subnet_a_cidr
  public_subnet_b_cidr   = var.public_subnet_b_cidr   
  private_subnet_cidr    = var.private_subnet_cidr
  availability_zone_a    = var.availability_zone_a
  availability_zone_b    = var.availability_zone_b

  tags = local.tags
}

# cidr is a method for efficiently allocating and routing IP addresses, 
# replacing older class-based systems to conserve IPv4 addresses and simplify internet routing. 
# It uses a compact "slash notation" (e.g., /24) to define an IP address range, 
# indicating how many bits are used for the network part, allowing for flexible network sizes and 
# better management of available IP space. 


# IP Address Structure: An IPv4 address has 32 bits, typically shown as four decimal numbers (e.g., 192.168.1.0).
# CIDR Notation: A "/n" suffix (like /24) is added, where 'n' is the number of bits used for the network portion of the address.
# Network Mask: The '/n' tells routers how many bits are fixed (network) and how many are variable (host), essentially defining a network mask.
# Example: In 192.168.1.0/24, the first 24 bits (192.168.1) identify the network, leaving the last 8 bits for host addresses

# =========================================================================
# SECURITY MODULE
# =========================================================================
module "security" {
  source = "./modules/security"

  project_name  = local.project_name
  environment   = local.environment
  vpc_id        = module.networking.vpc_id
  alb_port      = var.alb_port
  app_port      = var.app_port
  ssh_port      = var.ssh_port

  tags = local.tags
}

# =========================================================================
# LOAD BALANCER MODULE
# =========================================================================
module "load_balancer" {
  source = "./modules/load_balancer"

  project_name           = local.project_name
  environment            = local.environment
  vpc_id                 = module.networking.vpc_id
  public_subnets        = module.networking.public_subnet_ids
  alb_security_group_id = module.security.alb_sg_id
  app_port              = var.app_port
  alb_port              = var.alb_port
  health_check_path     = var.health_check_path
  health_check_matcher  = var.health_check_matcher

  tags = local.tags
}

# =========================================================================
# COMPUTE MODULE
# =========================================================================
module "compute" {
  source = "./modules/compute"

  project_name           = local.project_name
  environment            = local.environment
  bastion_subnet_id      = module.networking.public_subnet_a_id
  app_subnet_id          = module.networking.private_subnet_id
  bastion_sg_id          = module.security.bastion_sg_id
  app_sg_id              = module.security.app_sg_id
  bastion_instance_type  = var.bastion_instance_type
  app_instance_type      = var.app_instance_type
  key_name               = var.key_name
  target_group_arn       = module.load_balancer.target_group_arn
  app_port               = var.app_port
  # git_repository         = var.git_repository
  # app_environment_vars   = var.app_environment_vars

  tags = local.tags
}