#####################################
# NETWORK MODULE
#####################################
module "network" {
  source = "./network"

  key_name        = "terra-key-ec2"
  public_key_path = "${path.module}/terra-key-ec2.pub"

  azs = [
    "us-east-1a",
    "us-east-1b",
    "us-east-1c",
    "us-east-1d",
    "us-east-1f"
  ]

  ingress_ports = var.ingress_ports
}

#####################################
# EKS CLUSTER MODULE
#####################################
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.31"

  cluster_name    = var.cluster_name
  cluster_version = "1.29"

  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  enable_cluster_creator_admin_permissions = true

  vpc_id     = module.network.vpc_id
  subnet_ids = module.network.subnet_ids
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

      key_name = module.network.key_name

      vpc_security_group_ids = [
        module.network.security_group_id
      ]
    }
  }

  tags = {
    Environment = "dev"
  }

  depends_on = [module.network]
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

resource "time_sleep" "wait_for_eks" {
  depends_on = [module.eks]
  create_duration = "120s"
}

#####################################
# ADDONS MODULE
#####################################
module "addons" {
  source = "./addons"

  depends_on = [
    module.eks,
    time_sleep.wait_for_eks
  ]

  providers = {
    kubernetes = kubernetes
    helm       = helm
    kubectl    = kubectl
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