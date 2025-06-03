#!/bin/bash

# Deploy EKS Infrastructure
# This script automates the deployment of the EKS cluster

set -e

echo "🚀 Starting EKS Infrastructure Deployment..."

# Check prerequisites
echo "📋 Checking prerequisites..."

commands=("terraform" "aws" "kubectl")
for cmd in "${commands[@]}"; do
    if ! command -v $cmd &> /dev/null; then
        echo "❌ $cmd is not installed. Please install it first."
        exit 1
    fi
done

# Check AWS credentials
if ! aws sts get-caller-identity &> /dev/null; then
    echo "❌ AWS credentials not configured. Please run 'aws configure' first."
    exit 1
fi

echo "✅ Prerequisites check passed"

# Check if terraform.tfvars exists
if [ ! -f "terraform.tfvars" ]; then
    echo "⚠️  terraform.tfvars not found. Creating from example..."
    cp terraform.tfvars.example terraform.tfvars
    echo "📝 Please edit terraform.tfvars with your configuration and run this script again."
    exit 1
fi

# Initialize Terraform
echo "🔧 Initializing Terraform..."
terraform init

# Validate configuration
echo "🔍 Validating Terraform configuration..."
terraform validate

# Plan deployment
echo "📋 Planning deployment..."
terraform plan

# Ask for confirmation
read -p "Do you want to proceed with the deployment? (yes/no): " -r
echo
if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    echo "❌ Deployment cancelled."
    exit 1
fi

# Apply configuration
echo "🚀 Deploying infrastructure..."
terraform apply -auto-approve

# Get cluster info
CLUSTER_NAME=$(terraform output -raw cluster_name)
REGION=$(terraform output -raw region || echo "us-west-2")

# Configure kubectl
echo "⚙️  Configuring kubectl..."
aws eks update-kubeconfig --region $REGION --name $CLUSTER_NAME

# Test cluster connectivity
echo "🧪 Testing cluster connectivity..."
if kubectl cluster-info &> /dev/null; then
    echo "✅ Successfully connected to EKS cluster!"
    echo
    echo "📊 Cluster Information:"
    kubectl cluster-info
    echo
    echo "🎉 EKS cluster deployment completed successfully!"
    echo
    echo "📝 Next steps:"
    echo "   1. Deploy your applications to the cluster"
    echo "   2. Configure monitoring and logging"
    echo "   3. Set up ingress controllers if needed"
else
    echo "❌ Failed to connect to the cluster. Please check the AWS console."
    exit 1
fi
