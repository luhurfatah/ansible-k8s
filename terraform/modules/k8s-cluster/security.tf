# --- Security Groups ---

resource "aws_security_group" "lb_sg" {
  count       = var.enable_nlb ? 1 : 0
  name        = "${var.project_name}-lb-sg"
  description = "Security group for Load Balancer"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  dynamic "ingress" {
    for_each = var.enable_rke2_port ? [1] : []
    content {
      from_port   = 9345
      to_port     = 9345
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-lb-sg"
  }
}

resource "aws_security_group" "k8s_nodes_sg" {
  name        = "${var.project_name}-nodes-sg"
  description = "Security group for Kubernetes nodes"
  vpc_id      = aws_vpc.main.id

  # SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # K8s API Server (from LB)
  dynamic "ingress" {
    for_each = var.enable_nlb ? [1] : []
    content {
      from_port       = 6443
      to_port         = 6443
      protocol        = "tcp"
      security_groups = [aws_security_group.lb_sg[0].id]
    }
  }

  # K8s API Server (direct access when no NLB)
  dynamic "ingress" {
    for_each = var.enable_nlb ? [] : [1]
    content {
      from_port   = 6443
      to_port     = 6443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  # RKE2 Registration (from LB)
  dynamic "ingress" {
    for_each = var.enable_rke2_port && var.enable_nlb ? [1] : []
    content {
      from_port       = 9345
      to_port         = 9345
      protocol        = "tcp"
      security_groups = [aws_security_group.lb_sg[0].id]
    }
  }

  # Internal communication (all traffic between nodes)
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  # NodePort Services
  ingress {
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-nodes-sg"
  }
}
