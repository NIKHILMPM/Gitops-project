#####################################
# TERRAFORM + PROVIDERS
#####################################
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
    }
    helm = {
      source  = "hashicorp/helm"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

#####################################
# KEY PAIR
#####################################
resource "aws_key_pair" "my_public_key" {
  key_name   = "terra-key-ec2"
  public_key = file("${path.module}/terra-key-ec2.pub")
}

#####################################
# DEFAULT VPC
#####################################
resource "aws_default_vpc" "default" {}

data "aws_subnets" "eks_subnets" {
  filter {
    name   = "vpc-id"
    values = [aws_default_vpc.default.id]
  }

  # ✅ FILTER AZ HERE DIRECTLY
  filter {
    name = "availability-zone"
    values = [
      "us-east-1a",
      "us-east-1b",
      "us-east-1c",
      "us-east-1d",
      "us-east-1f"
    ]
  }
}

#####################################
# SECURITY GROUP
#####################################
resource "aws_security_group" "eks_sg" {
  name   = "eks-sg"
  vpc_id = aws_default_vpc.default.id

  dynamic "ingress" {
    for_each = var.ingress_ports

    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = [ingress.value.cidr]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#####################################
# EKS CLUSTER
#####################################
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.31"

  cluster_name    = var.cluster_name
  cluster_version = "1.29"

  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  enable_cluster_creator_admin_permissions = true

  vpc_id     = aws_default_vpc.default.id
  subnet_ids = data.aws_subnets.eks_subnets.ids   # ✅ FINAL FIX

  cluster_addons = {
    coredns    = {}
    kube-proxy = {}
    vpc-cni    = {}
  }

  eks_managed_node_groups = {
    default = {
      min_size     = 1
      max_size     = 2
      desired_size = 1

      instance_types = ["t3.large"]
      capacity_type  = "SPOT"

      key_name = aws_key_pair.my_public_key.key_name

      vpc_security_group_ids = [
        aws_security_group.eks_sg.id
      ]
    }
  }

  tags = {
    Environment = "dev"
  }
}
#####################################
# WAIT FOR EKS
#####################################
data "aws_eks_cluster" "cluster" {
  name       = module.eks.cluster_name
  depends_on = [module.eks]
}

data "aws_eks_cluster_auth" "cluster" {
  name       = module.eks.cluster_name
  depends_on = [module.eks]
}

#####################################
# KUBERNETES PROVIDER
#####################################
provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(
    data.aws_eks_cluster.cluster.certificate_authority[0].data
  )
  token = data.aws_eks_cluster_auth.cluster.token
}

#####################################
# HELM PROVIDER
#####################################
provider "helm" {
  kubernetes = {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(
      data.aws_eks_cluster.cluster.certificate_authority[0].data
    )

    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args = [
        "eks",
        "get-token",
        "--cluster-name",
        data.aws_eks_cluster.cluster.name
      ]
    }
  }
}

#####################################
# ADDONS MODULE
#####################################
module "addons" {
  source = "./addons"

  depends_on = [module.eks]

  providers = {
    kubernetes = kubernetes
    helm       = helm
  }

  github_username = var.github_username
  github_token    = var.github_token
  email = var.email
}

#####################################
# OUTPUTS
#####################################
output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}