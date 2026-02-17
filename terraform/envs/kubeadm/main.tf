terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

module "k8s" {
  source = "../../modules/k8s-cluster"

  project_name = "kubeadm-cluster"
  aws_region   = "us-east-1"
  ami_id       = "ami-0b6c6ebed2801a5cb" # Ubuntu 24.04 LTS (us-east-1)

  # Cluster sizing
  master_count     = 1
  worker_count     = 2
  instance_type    = "t3.medium"
  root_volume_size = 20

  # No NLB for kubeadm (single control plane)
  enable_nlb       = true
  enable_rke2_port = false

  # No extra EBS disks
  extra_ebs_count = 0
}

# --- Outputs ---

output "master_ips" {
  value = module.k8s.k8s_master_public_ips
}

output "worker_ips" {
  value = module.k8s.k8s_worker_public_ips
}

output "private_key_path" {
  value = module.k8s.private_key_path
}

output "nlb_dns" {
  value = module.k8s.nlb_dns_name
}
