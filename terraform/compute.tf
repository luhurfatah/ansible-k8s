# --- Key Pair ---
resource "tls_private_key" "k8s_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "k8s_key" {
  key_name   = "${var.project_name}-key"
  public_key = tls_private_key.k8s_key.public_key_openssh
}

resource "local_file" "private_key" {
  content         = tls_private_key.k8s_key.private_key_pem
  filename        = "${path.module}/${var.project_name}-key.pem"
  file_permission = "0400"
}

# --- EC2 Instances ---

resource "aws_instance" "k8s_master" {
  count         = 3
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = aws_key_pair.k8s_key.key_name
  subnet_id     = aws_subnet.public_a.id

  vpc_security_group_ids = [aws_security_group.k8s_nodes_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.k8s_node_profile.name

  tags = {
    Name = "${var.project_name}-master-${count.index + 1}"
    Role = "master"
  }
}

resource "aws_instance" "k8s_worker" {
  count         = 3
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = aws_key_pair.k8s_key.key_name
  subnet_id     = aws_subnet.public_a.id

  vpc_security_group_ids = [aws_security_group.k8s_nodes_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.k8s_node_profile.name

  tags = {
    Name = "${var.project_name}-worker-${count.index + 1}"
    Role = "worker"
  }
}
