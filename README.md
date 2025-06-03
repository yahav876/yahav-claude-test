# EKS Infrastructure with Terraform

This repository contains Terraform infrastructure code to create an Amazon EKS (Elastic Kubernetes Service) cluster on AWS.

## Architecture

This setup creates:
- VPC with public and private subnets across 2 availability zones
- Internet Gateway and NAT Gateways for connectivity
- EKS Cluster with managed node groups
- IAM roles and security groups
- ECR repository for container images

## Prerequisites

1. **AWS CLI** configured with appropriate credentials
2. **Terraform** >= 1.0
3. **kubectl** for Kubernetes cluster management
4. Appropriate AWS IAM permissions

## Quick Start

1. Clone this repository:
```bash
git clone https://github.com/yahav876/yahav-claude-test.git
cd yahav-claude-test
```

2. Initialize Terraform:
```bash
terraform init
```

3. Review and customize variables in `terraform.tfvars`:
```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your preferred values
```

4. Plan the deployment:
```bash
terraform plan
```

5. Apply the configuration:
```bash
terraform apply
```

6. Configure kubectl:
```bash
aws eks update-kubeconfig --region <your-region> --name <cluster-name>
```

## Configuration

Key variables you can customize:
- `cluster_name`: Name of your EKS cluster
- `region`: AWS region for deployment
- `node_instance_types`: EC2 instance types for worker nodes
- `node_desired_capacity`: Number of worker nodes

## Security

- Worker nodes are deployed in private subnets
- EKS cluster endpoint can be configured for private access
- Security groups follow least privilege principle
- IAM roles follow AWS best practices

## Cleanup

To destroy the infrastructure:
```bash
terraform destroy
```

**Note**: Make sure to delete any LoadBalancer services in your cluster first to avoid orphaned AWS resources.

## Costs

This infrastructure will incur AWS costs including:
- EKS cluster (~$73/month)
- EC2 instances for worker nodes
- NAT Gateway charges
- Data transfer costs

## Support

For issues or questions, please create an issue in this repository.
