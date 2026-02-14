# --- Network Load Balancer ---

resource "aws_lb" "k8s_api_nlb" {
  name               = "${var.project_name}-api-nlb"
  internal           = false
  load_balancer_type = "network"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = [aws_subnet.public_a.id, aws_subnet.public_b.id]

  enable_deletion_protection = false

  tags = {
    Name = "${var.project_name}-api-nlb"
  }
}

resource "aws_lb_target_group" "k8s_api_tg" {
  name     = "${var.project_name}-api-tg"
  port     = 6443
  protocol = "TCP"
  vpc_id   = aws_vpc.main.id

  health_check {
    enabled             = true
    interval            = 30
    path                = "/livez" # K8s health check endpoint
    port                = "6443"
    protocol            = "HTTPS"
    timeout             = 10
    healthy_threshold   = 3
    unhealthy_threshold = 3
    # matcher             = "200,401" # TCP health checks don't support matcher in the same way, but HTTPS does.
    # However, for NLB TCP target groups, we can still use HTTPS health checks.
  }
}

resource "aws_lb_listener" "k8s_api_listener" {
  load_balancer_arn = aws_lb.k8s_api_nlb.arn
  port              = "6443"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.k8s_api_tg.arn
  }
}

resource "aws_lb_target_group_attachment" "k8s_master_attachment" {
  count            = 3
  target_group_arn = aws_lb_target_group.k8s_api_tg.arn
  target_id        = aws_instance.k8s_master[count.index].id
  port             = 6443
}
