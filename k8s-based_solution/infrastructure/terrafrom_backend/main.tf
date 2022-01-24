# 
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.73.0"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
}

# Variables
variable "additional_tags" {
  default = {
    Environment    = "Test"
    DeploymentTool = "Terraform"
    Component      = "Shared"
  }
  description = "Additional tags"
  type        = map(string)
}

# KMS key for TF StateFile encryption
resource "aws_kms_key" "terraform-encryption-key" {
  description             = "This key is used to encrypt TF state bucket objects"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  tags = merge(
    var.additional_tags, {
    },
  )
}

# Alias for KMS key
resource "aws_kms_alias" "key-alias" {
  name          = "alias/terraform-encryption-key"
  target_key_id = aws_kms_key.terraform-encryption-key.key_id
}

# Creating S3 Bucket for Terraform State
resource "aws_s3_bucket" "terraform-state" {
  bucket = "tw-testinfrastructure-terraform-state"
  acl    = "private"

  # Enabling versioning for the TF State file.
  versioning {
    enabled = true
  }

  # Applying the KMS key to the bucket
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.terraform-encryption-key.key_id
        sse_algorithm     = "aws:kms"
      }
    }
  }

  tags = merge(
    var.additional_tags, {
    },
  )
}

# Defining ACL for the bucket
resource "aws_s3_bucket_public_access_block" "block" {
  bucket = aws_s3_bucket.terraform-state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Creating DynamoDB Table for Terraform State
resource "aws_dynamodb_table" "terraform-state" {
  name           = "terraform-state"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = merge(
    var.additional_tags, {
    },
  )
}
