output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_a_id" {
  value = aws_subnet.public_a.id
}

output "k8s_master_public_ips" {
  value = aws_instance.k8s_master[*].public_ip
}

output "k8s_worker_public_ips" {
  value = aws_instance.k8s_worker[*].public_ip
}

output "nlb_dns_name" {
  value = aws_lb.k8s_api_nlb.dns_name
}

output "private_key_path" {
  value = local_file.private_key.filename
}
