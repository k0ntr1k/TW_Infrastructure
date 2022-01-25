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

# # NETWORK COMPONENTS
# ## Create a VPC for Application
# resource "aws_vpc" "tw-app-vpc" {
#   cidr_block = "10.0.0.0/16"

#   tags = merge(
#     var.additional_tags, {
#       Component = "Shared"
#     },
#   )
# }

# ## Creating a Internet Gateway
# resource "aws_internet_gateway" "tw-app-internet-gateway" {
#   vpc_id = aws_vpc.tw-app-vpc.id

#   tags = merge(
#     var.additional_tags, {
#       Component = "Shared"
#     },
#   )
# }

# ## Create subnets for Application
# ### Subnet for Infrastructure components
# resource "aws_subnet" "tw-app-subnet-infra" {
#   vpc_id     = aws_vpc.tw-app-vpc.id
#   cidr_block = "10.0.100.0/24"

#   tags = merge(
#     var.additional_tags, {
#       Component = "Shared"
#     },
#   )
# }

# ### Subnet for Frontend components
# resource "aws_subnet" "tw-app-subnet-frontend" {
#   vpc_id     = aws_vpc.tw-app-vpc.id
#   cidr_block = "10.0.10.0/24"

#   tags = merge(
#     var.additional_tags, {
#       Component = "Frontend"
#     },
#   )
# }

# ### Subnet for Backend components
# resource "aws_subnet" "tw-app-subnet-backend" {
#   vpc_id     = aws_vpc.tw-app-vpc.id
#   cidr_block = "10.0.20.0/24"

#   tags = merge(
#     var.additional_tags, {
#       Component = "Backend"
#     },
#   )
# }

# ## Create a PublicIP for Frontend
# resource "aws_eip" "tw-app-pip" {
#   vpc = true

#   tags = merge(
#     var.additional_tags, {
#       Component = "Frontend"
#     },
#   )
# }

## Create a Load Balancer for Application
# resource "aws_lb" "tw-app-lb" {
#   name               = "App-LB"
#   load_balancer_type = "network"

#   subnet_mapping {
#     subnet_id     = aws_subnet.tw-app-subnet-frontend.id
#     allocation_id = aws_eip.tw-app-pip.id
#   }

#   tags = merge(
#     var.additional_tags, {
#       Component = "Frontend"
#     },
#   )
# }


# INFRASTRUCTURE COMPONENTS
## Create a AWS ECR Repository for Application
resource "aws_ecr_repository" "tw-app-ecr" {
  name                 = "tw-app-ecr"
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
  version                = "~> 1.21"
}

data "aws_availability_zones" "available" {
}

locals {
  cluster_name = "tw-eks-test-cluster"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.11.3"

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
      "Component" = "Shared"
      "kubernetes.io/cluster/${local.cluster_name}" = "shared"
      "kubernetes.io/role/elb"                      = "1"
    },
  )

  private_subnet_tags = merge(
    var.additional_tags, {
      "Component" = "Shared"
      "kubernetes.io/cluster/${local.cluster_name}" = "shared"
      "kubernetes.io/role/internal-elb"             = "1"
      },
  )
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "18.2.3"

  cluster_name    = local.cluster_name
  cluster_version = "1.21"
  subnets         = module.vpc.private_subnets

  vpc_id = module.vpc.vpc_id

  node_groups = {
    first = {
      desired_capacity = 2
      max_capacity     = 2
      min_capacity     = 2

      instance_type = "t4g.micro"
    }
  }

  write_kubeconfig   = true
  config_output_path = "./"
}