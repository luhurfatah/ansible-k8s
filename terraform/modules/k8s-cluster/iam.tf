# --- IAM Role for K8s Nodes ---

resource "aws_iam_role" "k8s_node_role" {
  name = "${var.project_name}-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-node-role"
  }
}

resource "aws_iam_role_policy_attachment" "node_ec2_policy" {
  role       = aws_iam_role.k8s_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_instance_profile" "k8s_node_profile" {
  name = "${var.project_name}-node-profile"
  role = aws_iam_role.k8s_node_role.name
}
