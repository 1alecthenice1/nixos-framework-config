#!/bin/bash

# Setup script for AWS CodeBuild infrastructure

set -e

echo "🚀 Setting up AWS CodeBuild for NixOS Framework ISO builds"
echo "=========================================================="

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "❌ AWS CLI is not installed. Please install it first:"
    echo "   https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
    exit 1
fi

# Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
    echo "❌ Terraform is not installed. Please install it first:"
    echo "   https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli"
    exit 1
fi

# Check AWS credentials
echo "🔍 Checking AWS credentials..."
if ! aws sts get-caller-identity &> /dev/null; then
    echo "❌ AWS credentials not configured. Please run:"
    echo "   aws configure"
    exit 1
fi

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REGION=$(aws configure get region || echo "us-east-1")

echo "✅ AWS Account: $ACCOUNT_ID"
echo "✅ AWS Region: $REGION"

# Navigate to terraform directory
cd aws-infrastructure

# Initialize and apply Terraform
echo "🏗️  Initializing Terraform..."
terraform init

echo "📋 Planning Terraform deployment..."
terraform plan

echo ""
read -p "Do you want to proceed with the deployment? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🚀 Deploying AWS infrastructure..."
    terraform apply -auto-approve
    
    echo ""
    echo "✅ AWS CodeBuild setup complete!"
    echo ""
    echo "Next steps:"
    echo "1. Add these secrets to your GitHub repository:"
    echo "   - AWS_ACCESS_KEY_ID (your AWS access key)"
    echo "   - AWS_SECRET_ACCESS_KEY (your AWS secret key)"
    echo ""
    echo "2. Push to master branch to trigger the AWS build"
    echo ""
    echo "The build will use a high-memory AWS instance with 128GB disk space."
else
    echo "❌ Deployment cancelled"
    exit 1
fi
