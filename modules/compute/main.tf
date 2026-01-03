# =========================================================================
# COMPUTE MODULE - MAIN.TF
# =========================================================================
# This module manages EC2 instances:
# - Bastion/Jump Host for secure access
# - Application server in private subnet
# - Target group attachment

# Latest Ubuntu AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# =========================================================================
# BASTION HOST
# =========================================================================

resource "aws_instance" "bastion" {
  ami             = data.aws_ami.ubuntu.id
  instance_type   = var.bastion_instance_type
  subnet_id       = var.bastion_subnet_id
  key_name        = var.key_name
  security_groups = [var.bastion_sg_id]

  associate_public_ip_address = true
  
  monitoring = var.enable_detailed_monitoring

  tags = merge(
    var.tags,
    { Name = "${var.project_name}-bastion" }
  )
}

# =========================================================================
# APPLICATION SERVER
# =========================================================================

resource "aws_instance" "app_server" {
  ami             = data.aws_ami.ubuntu.id
  instance_type   = var.app_instance_type
  subnet_id       = var.app_subnet_id
  key_name        = var.key_name
  security_groups = [var.app_sg_id]

  associate_public_ip_address = false
  
  monitoring = var.enable_detailed_monitoring

  # Minimal user_data for Ansible prerequisites
  user_data = base64encode(<<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y python3 python3-pip
              # Wait for cloud-init to complete
              cloud-init status --wait
              EOF
  )

  tags = merge(
    var.tags,
    { Name = "${var.project_name}-app-server" }
  )
}

# =========================================================================
# LOAD BALANCER TARGET GROUP ATTACHMENT
# =========================================================================

resource "aws_lb_target_group_attachment" "app" {
  target_group_arn = var.target_group_arn
  target_id        = aws_instance.app_server.id
  port             = var.app_port
}

# =========================================================================
# ANSIBLE PROVISIONER
# =========================================================================

resource "null_resource" "ansible_inventory_generator" {
  depends_on = [aws_instance.app_server, aws_instance.bastion]

  triggers = {
    app_server_id = aws_instance.app_server.id
    bastion_id = aws_instance.bastion.id
  }

  provisioner "local-exec" {
    command = <<-EOT
      # Create ansible directory if it doesn't exist
      mkdir -p ${path.root}/ansible
      
      # Generate inventory file for manual Ansible execution
      cat > ${path.root}/ansible/inventory.ini << EOF
[app_servers]
${aws_instance.app_server.private_ip} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/${var.key_name}.pem

[bastion]
${aws_instance.bastion.public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/${var.key_name}.pem

[app_servers:vars]
ansible_ssh_common_args='-o ProxyCommand="ssh -W %h:%p -q ubuntu@${aws_instance.bastion.public_ip}" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'
ansible_host_key_checking=False
EOF
      
      echo ""
      echo "=============================================================="
      echo "Ansible inventory generated at: ${path.root}/ansible/inventory.ini"
      echo "=============================================================="
      echo ""
      echo " To configure your application server, run:"
      echo ""
      echo "   cd ${path.root}/ansible"
      echo "   ansible-playbook -i inventory.ini playbook.yml -e 'git_repo=https://github.com/rivindu02/School-Management-API.git'"
      echo ""
      echo "=============================================================="
      echo ""
    EOT
  }
}