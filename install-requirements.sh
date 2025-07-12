#!/bin/bash

# Install AWS CLI and Terraform for AWS CodeBuild setup

set -e

echo "🚀 Installing AWS CLI and Terraform"
echo "===================================="

# Detect OS
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS="mac"
else
    echo "❌ Unsupported OS: $OSTYPE"
    exit 1
fi

# Install AWS CLI
echo "📦 Installing AWS CLI..."
if command -v aws &> /dev/null; then
    echo "✅ AWS CLI already installed: $(aws --version)"
else
    if [[ "$OS" == "linux" ]]; then
        # Linux installation
        curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
        unzip -q awscliv2.zip
        sudo ./aws/install
        rm -rf aws awscliv2.zip
    elif [[ "$OS" == "mac" ]]; then
        # macOS installation
        if command -v brew &> /dev/null; then
            brew install awscli
        else
            curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
            sudo installer -pkg AWSCLIV2.pkg -target /
            rm AWSCLIV2.pkg
        fi
    fi
    echo "✅ AWS CLI installed: $(aws --version)"
fi

# Install Terraform
echo "📦 Installing Terraform..."
if command -v terraform &> /dev/null; then
    echo "✅ Terraform already installed: $(terraform --version | head -1)"
else
    # Get latest Terraform version
    TERRAFORM_VERSION=$(curl -s https://api.github.com/repos/hashicorp/terraform/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')
    
    if [[ "$OS" == "linux" ]]; then
        # Linux installation
        wget -q "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip"
        unzip -q terraform_${TERRAFORM_VERSION}_linux_amd64.zip
        sudo mv terraform /usr/local/bin/
        rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip
    elif [[ "$OS" == "mac" ]]; then
        # macOS installation
        if command -v brew &> /dev/null; then
            brew tap hashicorp/tap
            brew install hashicorp/tap/terraform
        else
            wget -q "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_darwin_amd64.zip"
            unzip -q terraform_${TERRAFORM_VERSION}_darwin_amd64.zip
            sudo mv terraform /usr/local/bin/
            rm terraform_${TERRAFORM_VERSION}_darwin_amd64.zip
        fi
    fi
    echo "✅ Terraform installed: $(terraform --version | head -1)"
fi

echo ""
echo "🎉 Installation complete!"
echo ""
echo "Next steps:"
echo "1. Configure AWS credentials:"
echo "   aws configure"
echo ""
echo "2. Run the setup script:"
echo "   ./setup-aws-build.sh"
