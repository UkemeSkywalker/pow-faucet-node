resource "aws_key_pair" "deployer" {
  key_name   = "${var.instance_name}-key"
  public_key = file(var.ssh_public_key_path)
}

module "vpc" {
  source = "./modules/vpc"
  
  vpc_name = var.vpc_name
}

module "pow_faucet_node" {
  source = "./modules/ec2"
  
  instance_name      = var.instance_name
  key_name           = aws_key_pair.deployer.key_name
  vpc_id             = module.vpc.vpc_id
  subnet_id          = module.vpc.public_subnet_id
  allowed_tcp_ports  = [8080, 9090, 3000]
}