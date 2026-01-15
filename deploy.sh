#!/bin/bash

set -e

# Variables
SSH_KEY_PATH=${1:-"~/.ssh/id_rsa"}
SSH_PUBLIC_KEY_PATH="${SSH_KEY_PATH}.pub"

echo "🚀 Deploying PoWFaucet Node Infrastructure..."

# Check if SSH key exists
if [ ! -f "$SSH_PUBLIC_KEY_PATH" ]; then
    echo "❌ SSH public key not found at $SSH_PUBLIC_KEY_PATH"
    echo "Please generate SSH keys or provide the correct path as first argument"
    exit 1
fi

# Navigate to infra directory
cd infra

# Initialize Terraform
echo "📦 Initializing Terraform..."
terraform init

# Plan Terraform deployment
echo "📋 Planning Terraform deployment..."
terraform plan -var="ssh_public_key_path=$SSH_PUBLIC_KEY_PATH"

# Apply Terraform
echo "🏗️  Applying Terraform configuration..."
terraform apply -var="ssh_public_key_path=$SSH_PUBLIC_KEY_PATH" -auto-approve

# Get outputs
PUBLIC_IP=$(terraform output -raw instance_public_ip)
ELASTIC_IP=$(terraform output -raw elastic_ip)

echo "✅ Infrastructure deployed successfully!"
echo "📍 Public IP: $PUBLIC_IP"
echo "📍 Elastic IP: $ELASTIC_IP"

# Navigate back to config directory
cd ../config

# Create inventory file with actual IP
sed "s/{{ public_ip }}/$ELASTIC_IP/g; s|{{ ssh_key_path }}|$SSH_KEY_PATH|g" inventory.ini > inventory_actual.ini

# Wait for instance to be ready
echo "⏳ Waiting for instance to be ready..."
sleep 60

# Test SSH connectivity
echo "🔍 Testing SSH connectivity..."
for i in {1..10}; do
    if ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no -i "$SSH_KEY_PATH" ubuntu@"$ELASTIC_IP" "echo 'SSH connection successful'"; then
        echo "✅ SSH connection established"
        break
    else
        echo "⏳ SSH attempt $i/10 failed, retrying in 30 seconds..."
        sleep 30
    fi
done

# Run Ansible playbook
echo "start machine configuration...."
echo "🔧 Running Ansible playbook..."
ansible-playbook -i inventory_actual.ini setup-powfaucet.yml

echo "🎉 PoWFaucet Node deployment completed!"
echo "🌐 Access your faucet at: http://$ELASTIC_IP:8080"

# Clean up temporary inventory
rm inventory_actual.ini