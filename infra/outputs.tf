output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = module.pow_faucet_node.public_ip
}

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = module.pow_faucet_node.instance_id
}

output "elastic_ip" {
  description = "Elastic IP address"
  value       = module.pow_faucet_node.elastic_ip
}