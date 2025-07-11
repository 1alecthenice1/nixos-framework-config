# AWS CodeBuild project for building NixOS Framework ISO
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

variable "github_repo" {
  description = "GitHub repository URL"
  type        = string
  default     = "https://github.com/1alecthenice1/nixos-framework-config"
}

# S3 bucket for build artifacts
resource "aws_s3_bucket" "codebuild_artifacts" {
  bucket = "nixos-framework-iso-artifacts-${random_string.bucket_suffix.result}"
}

resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "aws_s3_bucket_versioning" "codebuild_artifacts" {
  bucket = aws_s3_bucket.codebuild_artifacts.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "codebuild_artifacts" {
  bucket = aws_s3_bucket.codebuild_artifacts.id

  rule {
    id     = "cleanup"
    status = "Enabled"

    expiration {
      days = 30
    }

    noncurrent_version_expiration {
      noncurrent_days = 7
    }
  }
}

# IAM role for CodeBuild
resource "aws_iam_role" "codebuild_role" {
  name = "nixos-framework-codebuild-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "codebuild_policy" {
  role = aws_iam_role.codebuild_role.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = "${aws_s3_bucket.codebuild_artifacts.arn}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = aws_s3_bucket.codebuild_artifacts.arn
      }
    ]
  })
}

# CodeBuild project
resource "aws_codebuild_project" "nixos_framework_iso" {
  name         = "nixos-framework-iso-build"
  description  = "Build NixOS Framework ISO with high memory/disk"
  service_role = aws_iam_role.codebuild_role.arn

  artifacts {
    type     = "S3"
    location = "${aws_s3_bucket.codebuild_artifacts.bucket}/artifacts"
  }

  environment {
    compute_type = "BUILD_GENERAL1_LARGE"  # 15GB memory, 128GB disk
    image        = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    type         = "LINUX_CONTAINER"

    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = var.aws_region
    }
  }

  source {
    type            = "GITHUB"
    location        = var.github_repo
    git_clone_depth = 1
    
    git_submodules_config {
      fetch_submodules = false
    }
  }

  source_version = "master"
}

# Output the project name and S3 bucket
output "codebuild_project_name" {
  value = aws_codebuild_project.nixos_framework_iso.name
}

output "artifacts_bucket" {
  value = aws_s3_bucket.codebuild_artifacts.bucket
}

output "setup_instructions" {
  value = <<-EOT
    To use this setup:
    
    1. Set up AWS credentials in GitHub Secrets:
       - AWS_ACCESS_KEY_ID
       - AWS_SECRET_ACCESS_KEY
    
    2. The CodeBuild project is: ${aws_codebuild_project.nixos_framework_iso.name}
    
    3. Artifacts will be stored in: ${aws_s3_bucket.codebuild_artifacts.bucket}
    
    4. Push to master branch to trigger the build via GitHub Actions
  EOT
}
