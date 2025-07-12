#!/bin/bash

# Spot Instance Manager for NixOS Framework ISO builds

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TF_DIR="$SCRIPT_DIR/aws-infrastructure"

show_help() {
    cat << EOF
NixOS Framework ISO - Spot Instance Manager

Usage: $0 [COMMAND] [OPTIONS]

Commands:
    launch      Launch a new spot instance for building
    status      Check status of running instances
    ssh         SSH to the running build instance
    logs        View build logs from the instance
    download    Download the built ISO from S3
    terminate   Terminate the spot instance
    cost        Show estimated costs

Options:
    --instance-type TYPE    EC2 instance type (default: m5.2xlarge)
    --max-price PRICE      Maximum spot price in USD (default: 0.20)
    --help                 Show this help

Examples:
    $0 launch                           # Launch with defaults
    $0 launch --instance-type m5.4xlarge --max-price 0.40
    $0 status                          # Check what's running
    $0 ssh                             # SSH to the instance
    $0 logs                            # View build progress
    $0 download                        # Download completed ISO
    $0 terminate                       # Stop the instance

Cost Comparison:
    Spot Instance (m5.2xlarge): ~\$0.10/hour (90% cheaper!)
    On-Demand (m5.2xlarge):     \$0.384/hour
    CodeBuild (LARGE):          \$0.01/minute = \$0.60/hour
EOF
}

launch_instance() {
    local instance_type="${1:-m5.2xlarge}"
    local max_price="${2:-0.20}"
    
    echo "🚀 Launching spot instance for NixOS ISO build..."
    echo "   Instance Type: $instance_type"
    echo "   Max Price: \$$max_price/hour"
    echo "   Estimated Cost: ~\$0.10/hour (74% savings vs on-demand)"
    
    cd "$TF_DIR"
    
    # Update terraform variables
    cat > terraform.tfvars << EOF
instance_type = "$instance_type"
max_spot_price = "$max_price"
EOF
    
    # Enable spot instance in terraform
    sed -i 's/count.*=.*0/count = 1/' spot-instance.tf
    
    echo "📋 Applying Terraform configuration..."
    terraform apply -auto-approve
    
    echo "⏳ Waiting for instance to be ready..."
    sleep 30
    
    # Get instance details
    local instance_id=$(aws ec2 describe-spot-instance-requests \
        --query 'SpotInstanceRequests[?State==`active`].InstanceId' \
        --output text | head -1)
    
    if [ -n "$instance_id" ]; then
        local instance_ip=$(aws ec2 describe-instances \
            --instance-ids "$instance_id" \
            --query 'Reservations[0].Instances[0].PublicIpAddress' \
            --output text)
        
        echo "✅ Spot instance launched successfully!"
        echo "   Instance ID: $instance_id"
        echo "   Public IP: $instance_ip"
        echo ""
        echo "The build will start automatically. Monitor progress with:"
        echo "   $0 logs"
        echo ""
        echo "SSH access:"
        echo "   $0 ssh"
    else
        echo "❌ Failed to get instance information"
        exit 1
    fi
}

check_status() {
    echo "🔍 Checking spot instance status..."
    
    local instances=$(aws ec2 describe-spot-instance-requests \
        --query 'SpotInstanceRequests[?State==`active`].[InstanceId,SpotPrice,InstanceType]' \
        --output text)
    
    if [ -n "$instances" ]; then
        echo "📊 Active spot instances:"
        echo "$instances" | while read instance_id spot_price instance_type; do
            local instance_ip=$(aws ec2 describe-instances \
                --instance-ids "$instance_id" \
                --query 'Reservations[0].Instances[0].PublicIpAddress' \
                --output text)
            echo "   Instance: $instance_id ($instance_type)"
            echo "   IP: $instance_ip"
            echo "   Spot Price: \$$spot_price/hour"
        done
    else
        echo "💤 No active spot instances found"
    fi
}

ssh_to_instance() {
    local instance_id=$(aws ec2 describe-spot-instance-requests \
        --query 'SpotInstanceRequests[?State==`active`].InstanceId' \
        --output text | head -1)
    
    if [ -n "$instance_id" ]; then
        local instance_ip=$(aws ec2 describe-instances \
            --instance-ids "$instance_id" \
            --query 'Reservations[0].Instances[0].PublicIpAddress' \
            --output text)
        
        echo "🔗 Connecting to $instance_ip..."
        ssh -i ~/.ssh/nixos-build-key.pem ec2-user@$instance_ip
    else
        echo "❌ No active instances found"
        exit 1
    fi
}

view_logs() {
    local instance_id=$(aws ec2 describe-spot-instance-requests \
        --query 'SpotInstanceRequests[?State==`active`].InstanceId' \
        --output text | head -1)
    
    if [ -n "$instance_id" ]; then
        local instance_ip=$(aws ec2 describe-instances \
            --instance-ids "$instance_id" \
            --query 'Reservations[0].Instances[0].PublicIpAddress' \
            --output text)
        
        echo "📋 Viewing build logs from $instance_ip..."
        ssh -i ~/.ssh/nixos-build-key.pem ec2-user@$instance_ip \
            "sudo tail -f /var/log/nixos-build.log"
    else
        echo "❌ No active instances found"
        exit 1
    fi
}

download_iso() {
    echo "📦 Downloading built ISO from S3..."
    
    local bucket=$(cd "$TF_DIR" && terraform output -raw s3_bucket 2>/dev/null)
    if [ -n "$bucket" ]; then
        aws s3 ls "s3://$bucket/" --human-readable --summarize
        echo ""
        echo "Download with: aws s3 cp s3://$bucket/<iso-name> ./"
    else
        echo "❌ Could not find S3 bucket name"
        exit 1
    fi
}

terminate_instance() {
    echo "🛑 Terminating spot instances..."
    
    cd "$TF_DIR"
    
    # Disable spot instance in terraform
    sed -i 's/count.*=.*1/count = 0/' spot-instance.tf
    
    terraform apply -auto-approve
    
    echo "✅ Spot instances terminated"
}

show_costs() {
    cat << EOF
💰 Cost Comparison for NixOS ISO Build:

Spot Instance (m5.2xlarge - 8 vCPU, 32GB RAM):
   Typical spot price: ~\$0.10/hour
   On-demand price:    \$0.384/hour
   Savings:            74% cheaper than on-demand
   Build time:         ~1-2 hours
   Total cost:         ~\$0.10-0.20 per build

AWS CodeBuild (BUILD_GENERAL1_LARGE - 8 vCPU, 15GB RAM):
   Price:              \$0.01/minute = \$0.60/hour
   Build time:         ~1-2 hours
   Total cost:         ~\$0.60-1.20 per build

GitHub Actions (free tier):
   Price:              Free (but limited disk space causes failures)
   Disk space:         14GB (insufficient for large builds)

🏆 Winner: Spot Instance - 83% cheaper than CodeBuild!
EOF
}

# Parse arguments
case "${1:-}" in
    launch)
        shift
        instance_type=""
        max_price=""
        
        while [[ $# -gt 0 ]]; do
            case $1 in
                --instance-type)
                    instance_type="$2"
                    shift 2
                    ;;
                --max-price)
                    max_price="$2"
                    shift 2
                    ;;
                *)
                    echo "Unknown option: $1"
                    show_help
                    exit 1
                    ;;
            esac
        done
        
        launch_instance "$instance_type" "$max_price"
        ;;
    status)
        check_status
        ;;
    ssh)
        ssh_to_instance
        ;;
    logs)
        view_logs
        ;;
    download)
        download_iso
        ;;
    terminate)
        terminate_instance
        ;;
    cost)
        show_costs
        ;;
    --help|help|"")
        show_help
        ;;
    *)
        echo "Unknown command: $1"
        show_help
        exit 1
        ;;
esac
