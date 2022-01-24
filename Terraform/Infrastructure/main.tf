# 
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.73.0"
    }
  }
  # Terraform Backend in S3
  backend "s3" {
    bucket         = "tw-testinfrastructure-terraform-state"
    key            = "terraform-state/tw-app-terraform.tfstate"
    region         = "eu-central-1"
    encrypt        = true
    kms_key_id     = "alias/terraform-encryption-key"
    dynamodb_table = "terraform-state"
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
  }
  description = "Additional tags"
  type        = map(string)
}


# KMS key for encryption
resource "aws_kms_key" "tw-app-kmskey" {
  description             = "This key is used to encrypt resources"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  tags = merge(
    var.additional_tags, {
      Component = "Shared"
    },
  )
}
# Alias for KMS key
resource "aws_kms_alias" "tw-app-kmskey-alias" {
  name          = "alias/tw-app-kmskey"
  target_key_id = aws_kms_key.tw-app-kmskey.key_id
}

# NETWORK COMPONENTS
# Create a VPC for Application
resource "aws_vpc" "tw-app-vpc" {
  cidr_block = "10.0.0.0/16"

  tags = merge(
    var.additional_tags, {
      Component = "Shared"
    },
  )
}

# Creating a Internet Gateway
resource "aws_internet_gateway" "tw-app-internet-gateway" {
  vpc_id = aws_vpc.tw-app-vpc.id

  tags = merge(
    var.additional_tags, {
      Component = "Shared"
    },
  )
}

# Create subnets for Application
## Subnet for Infrastructure components
resource "aws_subnet" "tw-app-subnet-infra" {
  vpc_id     = aws_vpc.tw-app-vpc.id
  cidr_block = "10.0.100.0/24"

  tags = merge(
    var.additional_tags, {
      Component = "Shared"
    },
  )
}

## Subnet for Frontend components
resource "aws_subnet" "tw-app-subnet-frontend" {
  vpc_id     = aws_vpc.tw-app-vpc.id
  cidr_block = "10.0.10.0/24"

  tags = merge(
    var.additional_tags, {
      Component = "Frontend"
    },
  )
}

## Subnet for Backend components
resource "aws_subnet" "tw-app-subnet-backend" {
  vpc_id     = aws_vpc.tw-app-vpc.id
  cidr_block = "10.0.20.0/24"

  tags = merge(
    var.additional_tags, {
      Component = "Backend"
    },
  )
}

# Create a PublicIP for Frontend
resource "aws_eip" "tw-app-pip" {
  vpc  = true

  tags = merge(
    var.additional_tags, {
      Component = "Frontend"
    },
  )
}

# Create a Load Balancer for Application
resource "aws_lb" "tw-app-lb" {
  name               = "App-LB"
  load_balancer_type = "network"

  subnet_mapping {
    subnet_id     = aws_subnet.tw-app-subnet-frontend.id
    allocation_id = aws_eip.tw-app-pip.id
  }

  tags = merge(
    var.additional_tags, {
      Component = "Frontend"
    },
  )
}


# INFRASTRUCTURE COMPONENTS
# Create a AWS ECR Repository for Application
resource "aws_ecr_repository" "tw-app-ecr" {
  name                 = "App-ECR"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(
    var.additional_tags, {
      Component = "Shared"
    },
  )
}
