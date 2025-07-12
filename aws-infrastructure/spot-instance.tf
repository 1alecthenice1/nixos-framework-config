# EC2 Spot Instance for NixOS ISO builds
# Much cheaper than CodeBuild - up to 90% savings!

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "m5.2xlarge"  # 8 vCPU, 32GB RAM, up to 10 Gbps network
}

variable "max_spot_price" {
  description = "Maximum spot price per hour (USD)"
  type        = string
  default     = "0.20"  # Usually ~$0.10/hour vs $0.384 on-demand
}

variable "key_pair_name" {
  description = "EC2 Key Pair name for SSH access"
  type        = string
  default     = "nixos-build-key"
}

# Get latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Security group for SSH access
resource "aws_security_group" "nixos_build" {
  name_prefix = "nixos-build-"
  description = "Security group for NixOS build instance"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Restrict this to your IP for security
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "nixos-build-sg"
  }
}

# IAM role for the instance
resource "aws_iam_role" "nixos_build_role" {
  name = "nixos-build-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_instance_profile" "nixos_build_profile" {
  name = "nixos-build-instance-profile"
  role = aws_iam_role.nixos_build_role.name
}

# S3 bucket for storing built ISOs
resource "aws_s3_bucket" "nixos_iso_storage" {
  bucket = "nixos-framework-isos-${random_string.bucket_suffix.result}"
}

resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "aws_iam_role_policy" "nixos_build_policy" {
  role = aws_iam_role.nixos_build_role.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject"
        ]
        Resource = "${aws_s3_bucket.nixos_iso_storage.arn}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = aws_s3_bucket.nixos_iso_storage.arn
      }
    ]
  })
}

# User data script to set up the build environment
locals {
  user_data = base64encode(templatefile("${path.module}/user-data.sh", {
    s3_bucket = aws_s3_bucket.nixos_iso_storage.bucket
  }))
}

# Launch template for spot instances
resource "aws_launch_template" "nixos_build" {
  name_prefix   = "nixos-build-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  key_name      = var.key_pair_name

  vpc_security_group_ids = [aws_security_group.nixos_build.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.nixos_build_profile.name
  }

  # Large root volume for Nix store
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 100  # 100GB should be plenty
      volume_type = "gp3"
      iops        = 3000
      throughput  = 125
    }
  }

  user_data = local.user_data

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "nixos-framework-build"
      Type = "spot-build-instance"
    }
  }
}

# Spot instance request
resource "aws_spot_instance_request" "nixos_build" {
  count                           = 0  # Set to 1 to launch
  ami                            = data.aws_ami.amazon_linux.id
  instance_type                  = var.instance_type
  key_name                       = var.key_pair_name
  security_groups                = [aws_security_group.nixos_build.name]
  spot_price                     = var.max_spot_price
  wait_for_fulfillment          = true
  spot_type                     = "one-time"
  instance_interruption_behavior = "terminate"

  root_block_device {
    volume_size = 100
    volume_type = "gp3"
  }

  user_data = local.user_data

  tags = {
    Name = "nixos-framework-build-spot"
  }
}

# Outputs
output "launch_template_id" {
  value = aws_launch_template.nixos_build.id
}

output "security_group_id" {
  value = aws_security_group.nixos_build.id
}

output "s3_bucket" {
  value = aws_s3_bucket.nixos_iso_storage.bucket
}

output "spot_instance_instructions" {
  value = <<-EOT
    To launch a spot instance for building:
    
    1. Update the spot instance count in main.tf:
       count = 1
    
    2. Apply terraform:
       terraform apply
    
    3. SSH to the instance:
       aws ec2 describe-spot-instance-requests --query 'SpotInstanceRequests[0].InstanceId' --output text
       ssh -i ~/.ssh/${var.key_pair_name}.pem ec2-user@<instance-ip>
    
    4. The build script will run automatically, or run manually:
       sudo /home/ec2-user/build-nixos-iso.sh
    
    5. ISO will be uploaded to: s3://${aws_s3_bucket.nixos_iso_storage.bucket}/
    
    Estimated cost: ~$0.10/hour vs $0.384/hour on-demand (74% savings!)
  EOT
}
