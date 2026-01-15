output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.pow_faucet_node.id
}

output "public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.pow_faucet_node.public_ip
}

output "elastic_ip" {
  description = "Elastic IP address"
  value       = aws_eip.pow_faucet_node_eip.public_ip
}

output "private_ip" {
  description = "Private IP address of the EC2 instance"
  value       = aws_instance.pow_faucet_node.private_ip
}