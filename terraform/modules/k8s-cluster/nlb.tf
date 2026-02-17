# --- Network Load Balancer (conditional) ---

resource "aws_lb" "k8s_api_nlb" {
  count              = var.enable_nlb ? 1 : 0
  name               = "${var.project_name}-api-nlb"
  internal           = false
  load_balancer_type = "network"
  security_groups    = [aws_security_group.lb_sg[0].id]
  subnets            = [aws_subnet.public_a.id, aws_subnet.public_b.id]

  enable_deletion_protection = false

  tags = {
    Name = "${var.project_name}-api-nlb"
  }
}

# --- API Target Group (6443) ---

resource "aws_lb_target_group" "k8s_api_tg" {
  count    = var.enable_nlb ? 1 : 0
  name     = "${var.project_name}-api-tcp-tg"
  port     = 6443
  protocol = "TCP"
  vpc_id   = aws_vpc.main.id

  health_check {
    enabled             = true
    interval            = 30
    port                = "6443"
    protocol            = "TCP"
    timeout             = 10
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

resource "aws_lb_listener" "k8s_api_listener" {
  count             = var.enable_nlb ? 1 : 0
  load_balancer_arn = aws_lb.k8s_api_nlb[0].arn
  port              = "6443"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.k8s_api_tg[0].arn
  }
}

resource "aws_lb_target_group_attachment" "k8s_master_api" {
  count            = var.enable_nlb ? var.master_count : 0
  target_group_arn = aws_lb_target_group.k8s_api_tg[0].arn
  target_id        = aws_instance.k8s_master[count.index].id
  port             = 6443
}

# --- RKE2 Registration Target Group (9345) ---

resource "aws_lb_target_group" "k8s_registration_tg" {
  count    = var.enable_rke2_port && var.enable_nlb ? 1 : 0
  name     = "${var.project_name}-reg-tg"
  port     = 9345
  protocol = "TCP"
  vpc_id   = aws_vpc.main.id

  health_check {
    enabled             = true
    interval            = 30
    port                = "9345"
    protocol            = "TCP"
    timeout             = 10
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

resource "aws_lb_listener" "k8s_registration_listener" {
  count             = var.enable_rke2_port && var.enable_nlb ? 1 : 0
  load_balancer_arn = aws_lb.k8s_api_nlb[0].arn
  port              = "9345"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.k8s_registration_tg[0].arn
  }
}

resource "aws_lb_target_group_attachment" "k8s_master_registration" {
  count            = var.enable_rke2_port && var.enable_nlb ? var.master_count : 0
  target_group_arn = aws_lb_target_group.k8s_registration_tg[0].arn
  target_id        = aws_instance.k8s_master[count.index].id
  port             = 9345
}
