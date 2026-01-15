# PoWFaucet Node Infrastructure

This directory contains Terraform infrastructure and Ansible configuration for deploying a PoWFaucet node.

## Infrastructure Specifications

- **Instance Type**: m5.xlarge (same as op-stack-l2-rollup-testnet)
- **OS**: Ubuntu (latest LTS)
- **Storage**: 1024GB gp3 EBS volume with encryption
- **Network**: Elastic IP with ports 22 (SSH) and 8080 (PoWFaucet) open
- **VPC**: Dedicated VPC with public subnet

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform installed
- Ansible installed
- SSH key pair generated locally

## Deployment

### Quick Deploy
```bash
./deploy.sh [path_to_ssh_private_key]
```

Example:
```bash
./deploy.sh ~/.ssh/id_rsa
```

### Manual Deploy

1. **Deploy Infrastructure**:
   ```bash
   cd infra
   terraform init
   terraform apply -var="ssh_public_key_path=~/.ssh/id_rsa.pub"
   ```

2. **Configure Ansible Inventory**:
   ```bash
   cd ../config
   # Update inventory.ini with the Elastic IP from Terraform output
   ```

3. **Run Ansible Playbook**:
   ```bash
   ansible-playbook -i inventory.ini setup-powfaucet.yml
   ```

## What Gets Deployed

The Ansible playbook will:
1. Install Node.js 18
2. Clone the PoWFaucet repository
3. Install dependencies for both main app and faucet-client
4. Build the faucet client
5. Create a systemd service for PoWFaucet
6. Start the PoWFaucet service

## Access

After deployment, access your PoWFaucet at: `http://[ELASTIC_IP]:8080`

## Cleanup

```bash
cd infra
terraform destroy -var="ssh_public_key_path=~/.ssh/id_rsa.pub"
```