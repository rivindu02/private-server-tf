# Infrastructure Technical Documentation

> Detailed technical reference for the Terraform modules and AWS infrastructure components.

## Architecture Diagram

```
                    ┌─────────────────┐
                    │  Internet       │
                    │  Gateway (IGW)  │
                    └────────┬────────┘
                             │
                    ┌────────┴─────────┐
                    │  Public Subnets  │
                    │  (2 AZs)         │
                    │                  │
         ┌──────────┴─────────┬────────┴──────────┐
         │                    │                    │
    ┌────┴────┐          ┌────┴────┐         ┌────┴────┐
    │ Bastion │          │   ALB   │         │   NAT   │
    │  Host   │          │         │         │ Gateway │
    └─────────┘          └────┬────┘         └────┬────┘
                              │                   │
                         ┌────┴────────────┬──────┘
                         │  Private Subnet │
                         │  10.0.2.0/24    │
                         │                 │
                    ┌────┴──────────────┐
                    │   App Servers     │
                    │   - Docker        │
                    │   - Node API      │
                    │   - MongoDB       │
                    └───────────────────┘
```

## Network Configuration

### VPC & Subnets
- **VPC CIDR:** 10.0.0.0/16
- **Public Subnet A:** 10.0.1.0/24 (ap-southeast-1a) - Bastion, NAT
- **Public Subnet B:** 10.0.3.0/24 (ap-southeast-1b) - ALB, Reserved
- **Private Subnet:** 10.0.2.0/24 (ap-southeast-1a) - Application servers

### Internet Connectivity
- **Internet Gateway (IGW):** Routes public subnet traffic to internet
- **NAT Gateway:** Enables outbound internet for private subnet
- **Route Tables:** Separate routing for public and private subnets

## Terraform Modules Reference

### Networking Module (`modules/networking/`)

Creates the foundational network infrastructure.

**Resources:**
- `aws_vpc` - Main VPC
- `aws_subnet` - Public (x2) and Private (x1) subnets
- `aws_internet_gateway` - Internet access for public subnets
- `aws_eip` - Elastic IP for NAT Gateway
- `aws_nat_gateway` - NAT for private subnet outbound traffic
- `aws_route_table` - Public and private routing tables
- `aws_route_table_association` - Subnet-to-route table associations

**Key Outputs:**
- `vpc_id` - VPC identifier
- `public_subnet_ids` - List of public subnet IDs
- `private_subnet_id` - Private subnet ID

### Security Module (`modules/security/`)

Manages all security group rules and network access control.

**Security Groups:**

1. **ALB Security Group**
   - Ingress: Port 80 (HTTP) from 0.0.0.0/0
   - Egress: All traffic

2. **Bastion Security Group**
   - Ingress: Port 22 (SSH) from 0.0.0.0/0
   - Egress: All traffic

3. **Application Security Group**
   - Ingress: Port 22 (SSH) from Bastion SG only
   - Ingress: Port 3000 (HTTP) from ALB SG only
   - Egress: All traffic

**Key Outputs:**
- `alb_sg_id` - ALB security group ID
- `bastion_sg_id` - Bastion security group ID
- `app_sg_id` - Application security group ID

### Compute Module (`modules/compute/`)

Provisions EC2 instances for bastion and application servers.

**Resources:**
- `aws_instance` (bastion) - Jump host in public subnet
- `aws_instance` (app_server) - Application server(s) in private subnet
- `local_file` - Generates Ansible inventory file

**AMI:** Ubuntu Server (latest, retrieved via data source)

**Key Outputs:**
- `bastion_public_ip` - Public IP for SSH access
- `app_server_private_ips` - Private IPs of application servers
- `ansible_inventory_path` - Path to generated inventory file

### Load Balancer Module (`modules/load_balancer/`)

Creates and configures the Application Load Balancer.

**Resources:**
- `aws_lb` - Application Load Balancer
- `aws_lb_target_group` - Target group (port 3000)
- `aws_lb_listener` - HTTP listener (port 80)
- `aws_lb_target_group_attachment` - Registers instances

**Health Check Configuration:**
- Path: `/`
- Port: 3000
- Protocol: HTTP
- Interval: 30s
- Timeout: 5s
- Healthy threshold: 2
- Unhealthy threshold: 2

**Key Outputs:**
- `alb_dns_name` - Public DNS name for accessing the application
- `alb_arn` - ALB Amazon Resource Name
- `target_group_arn` - Target group ARN



## Resource Naming Convention

All resources follow the pattern: `{project_name}-{resource_type}-{environment}`

Example: `school-tf-vpc-prod`, `school-tf-alb-prod`

## Common Operations

### Viewing Infrastructure State
```bash
# Show all resources
terraform state list

# Show specific resource
terraform state show module.networking.aws_vpc.main

# View outputs
terraform output
terraform output -json
```

### Updating Infrastructure
```bash
# Modify variables.tf or terraform.tfvars
# Then apply changes
terraform plan
terraform apply
```

### Accessing Instances via Bastion
```bash
# SSH to bastion (replace with your IP)
ssh -i ~/.ssh/your-key.pem ubuntu@<bastion-public-ip>

# From bastion, SSH to app server
ssh ubuntu@<app-private-ip>

# Check application status
docker ps
docker logs <container-name>
```

### Debugging

**Check Target Health:**
```bash
aws elbv2 describe-target-health \
  --target-group-arn <target-group-arn>
```

**View Security Group Rules:**
```bash
aws ec2 describe-security-groups \
  --group-ids <security-group-id>
```

**Instance Status:**
```bash
aws ec2 describe-instances \
  --filters "Name=tag:Project,Values=school-tf"
```

## Cost Optimization

Estimated monthly costs (ap-southeast-1, may vary):
- NAT Gateway: ~$32/month
- ALB: ~$16/month  
- EC2 t3.micro (bastion): ~$7.50/month
- EC2 t3.small (app): ~$15/month
- EBS Storage: ~$3-5/month
- Data Transfer: Variable

**Total: ~$75-85/month** (excluding data transfer)

### Cost-Saving Tips
- Use t3 instances with credits for burst performance
- Consider removing NAT Gateway for dev environments (use egress through bastion)
- Use Application Load Balancer only in production
- Enable auto-shutdown for non-production instances

## Security Considerations

### Implemented
✅ Private subnet for application servers  
✅ Bastion host for SSH access (no direct access to app servers)  
✅ Security groups with least-privilege access  
✅ No hardcoded credentials in code

### Recommended Enhancements
- Enable AWS CloudTrail for audit logging
- Use AWS Secrets Manager for sensitive data
- Implement VPC Flow Logs
- Add WAF rules to ALB
- Enable SSL/TLS with ACM certificates
- Restrict bastion SSH access by IP range
- Enable MFA for AWS console access
- Implement AWS Config for compliance

## Troubleshooting

### Issue: Terraform apply fails with "InvalidGroup.NotFound"
**Solution:** Security group dependencies. Wait a few seconds and retry, or add explicit `depends_on` in module.

### Issue: Cannot SSH to bastion
**Solution:** 
1. Check security group allows SSH from your IP
2. Verify SSH key permissions: `chmod 600 ~/.ssh/your-key.pem`
3. Confirm instance is running: `aws ec2 describe-instances`

### Issue: ALB returns 502 Bad Gateway
**Solution:**
1. Check target group health status
2. Verify application is running on correct port (3000)
3. Check app server security group allows traffic from ALB
4. Review application logs

### Issue: Terraform state lock error
**Solution:**
```bash
# If using S3 backend (optional)
terraform force-unlock <lock-id>
```

## Module Dependencies

```
main.tf
  ├── networking module
  │     └── Provides: VPC, Subnets, IGW, NAT, Routes
  ├── security module
  │     └── Requires: VPC ID
  │     └── Provides: Security Groups
  ├── compute module
  │     └── Requires: Subnet IDs, Security Group IDs
  │     └── Provides: Instance IPs
  └── load_balancer module
        └── Requires: VPC ID, Subnet IDs, Security Group IDs, Instance IDs
        └── Provides: ALB DNS Name
```

## Version History

- **v1.0** - Initial modular infrastructure
- **v1.1** - Fixed user_data and security group issues
- **v1.2** - Added Ansible integration

## Additional Resources

- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS VPC Best Practices](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-security-best-practices.html)
- [Terraform Module Best Practices](https://www.terraform.io/docs/modules/index.html)

---

For usage instructions, see the main [README.md](README.md).

