# =========================================================================
# LOAD BALANCER MODULE - MAIN.TF
# =========================================================================
# This module manages:
# - Application Load Balancer
# - Target Groups
# - Listeners and routing rules

resource "aws_lb" "main" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_security_group_id]    # module.security.alb_sg_id
  subnets            = var.public_subnets

  enable_deletion_protection = var.enable_deletion_protection
  enable_http2              = true
  enable_cross_zone_load_balancing = true  # improve availability

  tags = merge(
    var.tags,
    { Name = "${var.project_name}-alb" }
  )
}

# Target Group
resource "aws_lb_target_group" "main" {
  name_prefix = substr("${var.project_name}-tg", 0, 6)
  port        = var.app_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id

  health_check {
    path                = var.health_check_path
    matcher             = var.health_check_matcher
    interval            = var.health_check_interval
    timeout             = var.health_check_timeout
    healthy_threshold   = var.health_check_healthy_threshold
    unhealthy_threshold = var.health_check_unhealthy_threshold
  }

  deregistration_delay = var.deregistration_delay

  tags = merge(
    var.tags,
    { Name = "${var.project_name}-tg" }
  )

  lifecycle {
    create_before_destroy = true  # ensure new TG is created before old one is destroyed
  }
}

# Listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = var.alb_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}
