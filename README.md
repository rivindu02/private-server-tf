# AWS Infrastructure with Terraform & Ansible

[![Terraform](https://img.shields.io/badge/Terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)](https://www.terraform.io/)
[![Ansible](https://img.shields.io/badge/Ansible-%231A1918.svg?style=for-the-badge&logo=ansible&logoColor=white)](https://www.ansible.com/)
[![AWS](https://img.shields.io/badge/AWS-%23FF9900.svg?style=for-the-badge&logo=amazon-aws&logoColor=white)](https://aws.amazon.com/)
[![Docker](https://img.shields.io/badge/Docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white)](https://www.docker.com/)

> Production-ready infrastructure for deploying a School Management API on AWS using modular Terraform configuration with automated Ansible provisioning.

## 🏗️ Architecture Overview

This project deploys a highly available, secure AWS infrastructure with:

- **VPC** with public and private subnets across 2 availability zones
- **Application Load Balancer** (ALB) for traffic distribution
- **EC2 instances** in private subnet with Docker containerization
- **Bastion host** for secure SSH access
- **NAT Gateway** for private subnet internet access
- **Automated deployment** with Ansible

```
┌─────────────────────────────────────────────┐
│              Internet Gateway               │
└──────────────────┬──────────────────────────┘
                   │
        ┌──────────┴───────────┐
        │  Application Load    │
        │     Balancer         │
        │    (Port 80)         │
        └──────────┬───────────┘
                   │
    ┌──────────────┴─────────────────┐
    │                                 │
┌───┴────┐                    ┌──────┴──────┐
│Bastion │                    │   App       │
│ Host   │────SSH────────────▶│  Servers    │
│(Public)│                    │  (Private)  │
└────────┘                    │  - Node API │
                              │  - MongoDB  │
                              └─────────────┘
```

## 📋 Prerequisites

- [Terraform](https://www.terraform.io/downloads) >= 1.0
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) >= 2.9
- [AWS CLI](https://aws.amazon.com/cli/) configured with appropriate credentials
- SSH key pair for EC2 access

## 🚀 Quick Start

### 1. Clone the Repository

```bash
git clone <your-repo-url>
cd Private-server-tf
```

### 2. Configure Variables

**Important:** Edit `variables.tf` or create `terraform.tfvars`:

```hcl
# Required - Change to your AWS key pair name
key_name = "your-aws-keypair-name"

# Optional - Customize as needed
aws_region   = "ap-southeast-1"
project_name = "school-tf"
environment  = "prod"

# Instance configuration
instance_type = "t3.small"
```

**⚠️ Critical:** The default key name in variables.tf is `RVK-Server2`. You MUST change this to your actual AWS key pair name before deploying.

### 3. Configure Variables (Important!)

Edit `variables.tf` to set your SSH key name:

```hcl
variable "key_name" {
  description = "SSH key pair name for EC2 instances"
  type        = string
  default     = "your-key-pair-name"  # Change this!
}
```

### 4. Deploy Infrastructure

```bash
# Initialize Terraform
terraform init

# Review planned changes
terraform plan

# Apply configuration
terraform apply
```

### 5. Configure Application with Ansible

After Terraform completes:

```bash
cd ansible

# Wait 2-3 minutes for instances to be ready, then run:
ansible-playbook -i inventory.ini playbook.yml \
  -e 'git_repo=https://github.com/your-org/your-repo.git'
```

**Note:** Ansible will deploy the application to `/app` directory on the server.

### 6. Access Your Application

```bash
# Get the ALB DNS name
terraform output alb_dns_name

# Access your application
curl http://<alb-dns-name>
```

## 📁 Project Structure

```
.
├── main.tf                 # Root Terraform configuration
├── variables.tf            # Variable definitions
├── outputs.tf             # Output values
├── modules/               # Terraform modules
│   ├── networking/        # VPC, subnets, gateways
│   ├── security/          # Security groups
│   ├── compute/           # EC2 instances
│   └── load_balancer/     # Application Load Balancer
└── ansible/               # Ansible configuration
    ├── playbook.yml       # Main playbook
    ├── inventory.ini      # Auto-generated inventory
    └── vars.yml          # Ansible variables
```

## 🔧 Configuration

### Terraform Modules

#### Networking Module
- Creates VPC (10.0.0.0/16)
- 2 Public subnets (AZ A & B) for ALB and Bastion
- 1 Private subnet for application servers
- Internet Gateway and NAT Gateway
- Route tables and associations

#### Security Module
- ALB Security Group (HTTP from anywhere)
- Bastion Security Group (SSH from anywhere)
- App Security Group (SSH from Bastion, HTTP from ALB only)

#### Compute Module
- Bastion host in public subnet
- Application servers in private subnet
- Auto-generated Ansible inventory

#### Load Balancer Module
- Application Load Balancer
- Target group with health checks
- HTTP listener on port 80

### Ansible Configuration

The Ansible playbook automates:
1. System package updates
2. Docker and Docker Compose installation
3. Application repository cloning
4. Environment file creation
5. Container orchestration with Docker Compose

**Edit these files before deployment:**
- `ansible/vars.yml` - Application configuration (Git repo, environment variables)
- `ansible/inventory.ini` - Auto-generated by Terraform (verify IPs)

## 🔒 Security Best Practices

✅ Application servers in private subnet (no direct internet access)  
✅ SSH access only through bastion host  
✅ Security groups with least-privilege access  
✅ ALB for SSL/TLS termination capability  
✅ NAT Gateway for outbound traffic from private subnet  

## 📊 Outputs

After `terraform apply`, you'll get:

- **VPC ID** - Your VPC identifier
- **ALB DNS Name** - Access your application via this URL
- **Bastion Public IP** - SSH entry point
- **App Server Private IPs** - Backend server addresses

View outputs anytime:
```bash
terraform output
```

## 🔄 Updating Your Application

To update the application code without rebuilding infrastructure:

```bash
cd ansible
ansible-playbook -i inventory.ini playbook.yml \
  -e 'git_repo=https://github.com/your-org/your-repo.git' \
  --tags "deploy"
```

## 🧹 Cleanup

To destroy all resources:

```bash
terraform destroy
```

**⚠️ Warning:** This will permanently delete all resources. Backup any important data first.

## 📝 Variables Reference

| Variable | Description | Default |
|----------|-------------|---------|
| `aws_region` | AWS region | `ap-southeast-1` |
| `project_name` | Project identifier | `school-tf` |
| `environment` | Environment name | `prod` |
| `instance_type` | EC2 instance type | `t2.micro` |
| `key_name` | SSH key pair name | Required |

See [variables.tf](variables.tf) for complete list.

## 🐛 Troubleshooting

### Cannot connect to instances
- Verify security groups allow SSH from your IP
- Check bastion host is running: `aws ec2 describe-instances`
- Ensure SSH key permissions: `chmod 600 ~/.ssh/your-key.pem`
- Confirm key name in variables.tf matches your AWS key pair

### Ansible fails to connect
- Wait 2-3 minutes after `terraform apply` for instances to initialize
- Verify inventory.ini has correct IPs: `cat ansible/inventory.ini`
- Test bastion connectivity: `ssh -i ~/.ssh/your-key.pem ubuntu@<bastion-ip>`

### Application not accessible via ALB
- Check target health: AWS Console → EC2 → Target Groups
- Verify Docker containers are running: `docker ps`
- Check application logs: `docker logs <container-name>`

## 🤝 Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on:
- Development workflow
- Code style standards
- Testing requirements
- Pull request process

Quick start:
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes and test thoroughly
4. Commit changes (`git commit -m 'Add amazing feature'`)
5. Push to branch (`git push origin feature/amazing-feature`)
6. Open a Pull Request

## 📄 License

This project is provided as-is for educational and production use.

## 🔗 Additional Resources

- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Ansible Documentation](https://docs.ansible.com/)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)

---

**Built with** ❤️ **using Terraform and Ansible**
