# Main Terraform file for provisioning Infrastructure for Application
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.73.0"
    }
  }

  # Terraform Backend in S3
  # Backend should be create before.
  # For more information go to "../terraform_backend" folder
  backend "s3" {
    # paste here value from 'terraform_backend' output
    ## s3_bucket:
    bucket  = "tw-testinfrastructure-terraform-state"
    key     = "terraform-state/tw-app-terraform.tfstate"
    region  = "eu-central-1"
    encrypt = true
    # paste here value from 'terraform_backend' output
    ## kms_key:
    kms_key_id = "alias/terraform-encryption-key"
    # paste here value from 'terraform_backend' output
    ## dynamodb_table
    dynamodb_table = "terraform-state"
  }
}

# Defining Cloud provider and Region
provider "aws" {
  region = "eu-central-1"
}

# Variables
## Defining Tags
variable "additional_tags" {
  default = {
    Environment    = "Test"
    DeploymentTool = "Terraform"
  }
  description = "Additional tags"
  type        = map(string)
}

# INFRASTRUCTURE COMPONENTS
## Create a AWS ECR Repository for frontend-service
resource "aws_ecr_repository" "frontend-service" {
  name                 = "frontend-service"
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

## Create a AWS ECR Repository for newsfeed-service
resource "aws_ecr_repository" "newsfeed-service" {
  name                 = "newsfeed-service"
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

## Create a AWS ECR Repository for quotes-service
resource "aws_ecr_repository" "quotes-service" {
  name                 = "quotes-service"
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

## Create a AWS ECR Repository for static-service
resource "aws_ecr_repository" "static-service" {
  name                 = "static-service"
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

## Create an EKS cluster for run Application
### Create EKS
data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
}

data "aws_availability_zones" "available" {
}

locals {
  cluster_name   = "tw-eks-test-cluster"
  instance_types = "t3.medium"
  k8s_version    = "1.21"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name                 = "tw-app-k8s-vpc"
  cidr                 = "172.16.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = ["172.16.1.0/24", "172.16.2.0/24", "172.16.3.0/24"]
  public_subnets       = ["172.16.4.0/24", "172.16.5.0/24", "172.16.6.0/24"]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = merge(
    var.additional_tags, {
      "Component"                                   = "Shared"
      "kubernetes.io/cluster/${local.cluster_name}" = "shared"
      "kubernetes.io/role/elb"                      = "1"
    },
  )

  private_subnet_tags = merge(
    var.additional_tags, {
      "Component"                                   = "Shared"
      "kubernetes.io/cluster/${local.cluster_name}" = "shared"
      "kubernetes.io/role/internal-elb"             = "1"
    },
  )
}

resource "aws_security_group" "additional" {
  name        = "SG Additional for EKS"
  description = "Allow traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

module "eks" {
  source = "terraform-aws-modules/eks/aws"

  cluster_name                    = local.cluster_name
  cluster_version                 = local.k8s_version
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  cluster_addons = {
    coredns = {
      resolve_conflicts = "OVERWRITE"
    }
    kube-proxy = {}
    vpc-cni = {
      resolve_conflicts = "OVERWRITE"
    }
  }

  eks_managed_node_group_defaults = {
    ami_type               = "AL2_x86_64"
    disk_size              = 20
    instance_types         = [local.instance_types]
    vpc_security_group_ids = [aws_security_group.additional.id]
  }

  eks_managed_node_groups = {
    blue = {}
    green = {
      min_size     = 1
      max_size     = 2
      desired_size = 1

      instance_types = [local.instance_types]
      capacity_type  = "SPOT"
      labels = merge(
        var.additional_tags, {
          "Component" = "Shared"
        },
      )
      taints = {
        dedicated = {
          key    = "dedicated"
          value  = "gpuGroup"
          effect = "NO_SCHEDULE"
        }
      }
      tags = merge(
        var.additional_tags, {
          "Component" = "Shared"
        },
      )
    }
  }
}
