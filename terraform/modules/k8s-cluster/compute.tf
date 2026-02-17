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
  filename        = "${path.root}/${var.project_name}-key.pem"
  file_permission = "0400"
}

# --- EC2 Master Instances ---

resource "aws_instance" "k8s_master" {
  count         = var.master_count
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = aws_key_pair.k8s_key.key_name
  subnet_id     = aws_subnet.public_a.id

  vpc_security_group_ids = [aws_security_group.k8s_nodes_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.k8s_node_profile.name

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = "gp3"
  }

  tags = {
    Name = "${var.project_name}-master-${count.index + 1}"
    Role = "master"
  }
}

# --- EC2 Worker Instances ---

locals {
  # Device name letters starting from 'b': /dev/sdb, /dev/sdc, /dev/sdd, ...
  ebs_device_letters = ["b", "c", "d", "e", "f", "g", "h"]
}

resource "aws_instance" "k8s_worker" {
  count         = var.worker_count
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = aws_key_pair.k8s_key.key_name
  subnet_id     = aws_subnet.public_a.id

  vpc_security_group_ids = [aws_security_group.k8s_nodes_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.k8s_node_profile.name

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = "gp3"
  }

  # Dynamically attach extra EBS disks (e.g. for Rook Ceph OSDs)
  dynamic "ebs_block_device" {
    for_each = range(var.extra_ebs_count)
    content {
      device_name = "/dev/sd${local.ebs_device_letters[ebs_block_device.value]}"
      volume_size = var.extra_ebs_size
      volume_type = "gp3"
    }
  }

  tags = {
    Name = "${var.project_name}-worker-${count.index + 1}"
    Role = "worker"
  }
}
