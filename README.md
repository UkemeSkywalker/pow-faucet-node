# PoWFaucet Node Infrastructure

Automated deployment of a PoWFaucet node with monitoring stack on AWS using Terraform and Ansible.

## Infrastructure Specifications

- **Instance Type**: t3.medium
- **OS**: Ubuntu (latest LTS)
- **Storage**: 20GB gp3 EBS volume with encryption
- **Network**: Elastic IP with security group
- **VPC**: Dedicated VPC with public subnet

### Open Ports
- 22 (SSH)
- 8080 (PoWFaucet)
- 9090 (Prometheus)
- 3000 (Grafana)

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform >= 1.0
- Ansible >= 2.9
- SSH key pair generated locally
- Alchemy or infura ETH RPC Url
## Setup

1. **Configure Environment Variables**:
   ```bash
   cp .env.example .env
   ```
   
   Edit `.env` and add:
   - `ETH_RPC_URL`: Your Ethereum RPC endpoint (Alchemy/Infura)
   - `ETH_WALLET_PRIVATE_KEY`: Faucet wallet private key (without 0x prefix)

2. **Configure Faucet Settings** (Optional):
   Edit `config/faucet-config.yaml.j2` to customize:
   - Faucet title and branding
   - Mining difficulty and rewards
   - Protection mechanisms (captcha, rate limits, etc.)
   - Network-specific settings

## Deployment

### Quick Deploy
```bash
./deploy.sh [path_to_ssh_private_key]
```

Example:
```bash
./deploy.sh ~/.ssh/id_rsa
```

The script will:
1. Load environment variables from `.env`
2. Deploy AWS infrastructure with Terraform
3. Configure the instance with Ansible
4. Display access URLs

### Manual Deploy

1. **Load Environment Variables**:
   ```bash
   export $(cat .env | grep -v '^#' | xargs)
   ```

2. **Deploy Infrastructure**:
   ```bash
   cd infra
   terraform init
   terraform apply -var="ssh_public_key_path=~/.ssh/id_rsa.pub"
   ```

3. **Configure Ansible Inventory**:
   ```bash
   cd ../config
   # Update inventory.ini with the Elastic IP from Terraform output
   ```

4. **Run Ansible Playbook**:
   ```bash
   ansible-playbook -i inventory.ini setup-powfaucet.yml
   ```

## What Gets Deployed

### PoWFaucet Application
- Node.js 24
- PoWFaucet from official repository
- Custom configuration from template
- Systemd service for auto-start

### Monitoring Stack
- **Prometheus** (port 9090): Metrics collection and storage
- **Grafana** (port 3000): Metrics visualization and dashboards
  - Default credentials: `admin/admin` (change on first login)

## Access

After deployment:
- **PoWFaucet**: `http://[ELASTIC_IP]:8080`
- **Prometheus**: `http://[ELASTIC_IP]:9090`
- **Grafana**: `http://[ELASTIC_IP]:3000`

## Project Structure

```
pow-faucet-node/
├── infra/                    # Terraform infrastructure
│   ├── modules/
│   │   ├── ec2/             # EC2 instance and security group
│   │   └── vpc/             # VPC and networking
│   ├── main.tf              # Main configuration
│   ├── variables.tf         # Input variables
│   └── outputs.tf           # Output values
├── config/                   # Ansible configuration
│   ├── setup-powfaucet.yml  # Main playbook
│   ├── faucet-config.yaml.j2 # Faucet config template
│   └── inventory.ini        # Inventory template
├── .env                      # Environment variables (not in git)
├── .env.example             # Environment template
└── deploy.sh                # Automated deployment script
```

## Configuration Management

The faucet configuration uses Jinja2 templates for dynamic values:
- Environment variables from `.env` are injected during deployment
- Template location: `config/faucet-config.yaml.j2`
- Deployed to: `/home/ubuntu/PoWFaucet/faucet-client/faucet-config.yaml`

## Monitoring Setup

### Prometheus
- Scrapes its own metrics
- Ready for additional exporters (node_exporter, custom metrics)
- Data stored in `/var/lib/prometheus`

### Grafana
- Pre-installed, ready for dashboard configuration
- Add Prometheus as data source: `http://localhost:9090`
- Import community dashboards or create custom ones

## Maintenance

### View Logs
```bash
ssh -i ~/.ssh/id_rsa ubuntu@[ELASTIC_IP]
sudo journalctl -u powfaucet -f
sudo journalctl -u prometheus -f
sudo journalctl -u grafana-server -f
```

### Restart Services
```bash
sudo systemctl restart powfaucet
sudo systemctl restart prometheus
sudo systemctl restart grafana-server
```

### Update Configuration
1. Edit `config/faucet-config.yaml.j2` locally
2. Re-run Ansible:
   ```bash
   cd config
   ansible-playbook -i inventory_actual.ini setup-powfaucet.yml
   ```

## Cleanup

```bash
cd infra
terraform destroy -var="ssh_public_key_path=~/.ssh/id_rsa.pub"
```

## Security Notes

- Never commit `.env` file to version control
- Keep your private keys secure
- Change Grafana default password immediately
- Consider restricting port access to specific IPs in production
- Regularly update the faucet wallet with funds
- Monitor for unusual activity

## Troubleshooting

### SSH Connection Issues
- Ensure security group allows SSH from your IP
- Verify SSH key permissions: `chmod 600 ~/.ssh/id_rsa`
- Wait 1-2 minutes after instance creation

### Faucet Not Starting
- Check logs: `sudo journalctl -u powfaucet -n 50`
- Verify RPC URL is accessible
- Ensure wallet has sufficient funds
- Validate configuration: `cd /home/ubuntu/PoWFaucet && npm run start`

### Environment Variables Not Applied
- Ensure `.env` file exists in project root
- Verify variables are exported before running Ansible
- Check template rendering in deployed config file