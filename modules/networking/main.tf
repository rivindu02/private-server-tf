# =========================================================================
# NETWORKING MODULE - MAIN.TF
# =========================================================================
# This module handles all VPC networking resources including:
# - VPC Creation
# - Public & Private Subnets
# - Internet Gateway
# - NAT Gateway
# - Route Tables and Associations

# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    var.tags,
    { Name = "${var.project_name}-vpc" }
  )
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.tags,
    { Name = "${var.project_name}-igw" }
  )
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = merge(
    var.tags,
    { Name = "${var.project_name}-nat-eip" }
  )

  depends_on = [aws_internet_gateway.main]
}

# =========================================================================
# PUBLIC SUBNETS
# =========================================================================

resource "aws_subnet" "public_a" {        # this subnet will host the NAT gateway
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_a_cidr
  availability_zone       = var.availability_zone_a
  map_public_ip_on_launch = true

  tags = merge(
    var.tags,
    { Name = "${var.project_name}-public-subnet-a" }
  )
}

resource "aws_subnet" "public_b" {        
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_b_cidr
  availability_zone       = var.availability_zone_b
  map_public_ip_on_launch = true

  tags = merge(
    var.tags,
    { Name = "${var.project_name}-public-subnet-b" }
  )
}

# =========================================================================
# PRIVATE SUBNET
# =========================================================================

resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet_cidr
  availability_zone       = var.availability_zone_a
  map_public_ip_on_launch = false   # Private subnet does not assign public IPs

  tags = merge(
    var.tags,
    { Name = "${var.project_name}-private-subnet" }
  )
}

# =========================================================================
# NAT GATEWAY
# =========================================================================

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_a.id

  tags = merge(
    var.tags,
    { Name = "${var.project_name}-nat-gw" }
  )

  depends_on = [aws_internet_gateway.main]
}

# =========================================================================
# ROUTE TABLES
# =========================================================================

# This configuration defines two route tables: one for public routes and another for private routes.
# 
# - Public Route Table:
#   - Associated with subnets that require direct internet access.
#   - Contains a route to the Internet Gateway (IGW) for outbound internet traffic.
# 
# - Private Route Table:
#   - Associated with subnets that do not require direct internet access.
#   - Contains a route to the NAT Gateway, allowing instances in private subnets to access the internet for updates or other outbound traffic while remaining inaccessible from the internet.


# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id   
  }

  tags = merge(
    var.tags,
    { Name = "${var.project_name}-public-rt" }
  )
}

# Private Route Table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id    
  }

  tags = merge(
    var.tags,
    { Name = "${var.project_name}-private-rt" }
  )
}

# =========================================================================
# ROUTE TABLE ASSOCIATIONS
# =========================================================================

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}
