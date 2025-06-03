#!/bin/bash

# Destroy EKS Infrastructure
# This script safely destroys the EKS cluster and all associated resources

set -e

echo "🗑️  EKS Infrastructure Destruction Script"
echo "⚠️  WARNING: This will destroy all resources created by Terraform!"
echo

# Check if Terraform is initialized
if [ ! -d ".terraform" ]; then
    echo "❌ Terraform not initialized. Please run 'terraform init' first."
    exit 1
fi

# Show what will be destroyed
echo "📋 Planning destruction..."
terraform plan -destroy

echo
echo "⚠️  DANGER ZONE ⚠️"
echo "This will permanently delete:"
echo "  - EKS Cluster and all workloads"
echo "  - EC2 instances (worker nodes)"
echo "  - VPC and networking components"
echo "  - ECR repository and images"
echo "  - All associated AWS resources"
echo

# Double confirmation
read -p "Are you absolutely sure you want to destroy everything? Type 'destroy' to confirm: " -r
echo
if [[ ! $REPLY == "destroy" ]]; then
    echo "❌ Destruction cancelled."
    exit 1
fi

# Get cluster info before destruction
if [ -f "terraform.tfstate" ]; then
    CLUSTER_NAME=$(terraform output -raw cluster_name 2>/dev/null || echo "unknown")
    echo "🗑️  Destroying cluster: $CLUSTER_NAME"
fi

# Check for LoadBalancer services that might create orphaned resources
echo "🔍 Checking for LoadBalancer services..."
if command -v kubectl &> /dev/null && kubectl cluster-info &> /dev/null; then
    LB_SERVICES=$(kubectl get svc --all-namespaces -o jsonpath='{.items[?(@.spec.type=="LoadBalancer")].metadata.name}' 2>/dev/null || echo "")
    if [ ! -z "$LB_SERVICES" ]; then
        echo "⚠️  Found LoadBalancer services: $LB_SERVICES"
        echo "   These should be deleted manually to avoid orphaned AWS resources."
        read -p "Do you want to continue anyway? (yes/no): " -r
        if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
            echo "❌ Destruction cancelled."
            exit 1
        fi
    fi
fi

# Destroy infrastructure
echo "💥 Destroying infrastructure..."
terraform destroy -auto-approve

echo "✅ Infrastructure destruction completed!"
echo
echo "📝 Post-destruction checklist:"
echo "   1. Verify no orphaned AWS resources remain"
echo "   2. Check AWS billing for any unexpected charges"
echo "   3. Remove local kubeconfig entries if needed"
echo "   4. Clean up local Terraform state if desired"
