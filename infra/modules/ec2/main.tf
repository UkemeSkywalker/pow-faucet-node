resource "aws_eip" "pow_faucet_node_eip" {
  domain   = "vpc"
  instance = aws_instance.pow_faucet_node.id

  tags = {
    Name = "${var.instance_name}-eip"
  }
}

resource "aws_instance" "pow_faucet_node" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = var.key_name
  subnet_id     = var.subnet_id
  
  vpc_security_group_ids = [aws_security_group.pow_faucet_node.id]
  
  root_block_device {
    volume_type = "gp3"
    volume_size = var.volume_size
    iops        = 3000
    throughput  = 125
    encrypted   = true
  }

  tags = {
    Name = var.instance_name
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_security_group" "pow_faucet_node" {
  name_prefix = "${var.instance_name}-"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.allowed_tcp_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = var.allowed_cidr_blocks
    }
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}