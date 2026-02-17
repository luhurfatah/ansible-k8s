variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project (used as prefix for all resources)"
  type        = string
  default     = "k8s-cluster"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.1.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the first public subnet"
  type        = string
  default     = "10.1.1.0/24"
}

variable "public_subnet_b_cidr" {
  description = "CIDR block for the second public subnet"
  type        = string
  default     = "10.1.2.0/24"
}

variable "instance_type" {
  description = "EC2 instance type for all nodes"
  type        = string
  default     = "t3.medium"
}

variable "ami_id" {
  description = "AMI ID for EC2 instances"
  type        = string
}

# --- Cluster Sizing ---

variable "master_count" {
  description = "Number of master/control-plane nodes"
  type        = number
  default     = 3
}

variable "worker_count" {
  description = "Number of worker nodes"
  type        = number
  default     = 3
}

variable "root_volume_size" {
  description = "Root EBS volume size in GB"
  type        = number
  default     = 20
}

# --- NLB ---

variable "enable_nlb" {
  description = "Whether to create a Network Load Balancer for the API server"
  type        = bool
  default     = false
}

# --- RKE2-Specific ---

variable "enable_rke2_port" {
  description = "Whether to open port 9345 (RKE2 registration) on SG and NLB"
  type        = bool
  default     = false
}

# --- Extra EBS Disks (for Rook Ceph, etc.) ---

variable "extra_ebs_count" {
  description = "Number of additional EBS disks to attach to each worker node"
  type        = number
  default     = 0
}

variable "extra_ebs_size" {
  description = "Size (GB) of each additional EBS disk"
  type        = number
  default     = 5
}
