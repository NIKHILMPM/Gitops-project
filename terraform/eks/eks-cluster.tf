#####################################
# EKS CLUSTER + NODE GROUP
#####################################

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.15.1"

  cluster_name                   = var.cluster_name
  cluster_endpoint_public_access = true

  #####################################
  # ADDONS
  #####################################
  cluster_addons = {
    coredns            = { most_recent = true }
    kube-proxy         = { most_recent = true }
    vpc-cni            = { most_recent = true }
    aws-ebs-csi-driver = { most_recent = true }
  }

  #####################################
  # NETWORK
  #####################################
  vpc_id                   = aws_default_vpc.default.id
  subnet_ids               = data.aws_subnets.default.ids
  control_plane_subnet_ids = data.aws_subnets.default.ids

  #####################################
  # NODE GROUP
  #####################################
  eks_managed_node_groups = {
    default = {
      min_size     = 1
      max_size     = 2
      desired_size = 1

      instance_types = ["t3.xlarge"]
      capacity_type  = "SPOT"
      disk_size      = 15

      key_name = aws_key_pair.my_public_key.key_name

      vpc_security_group_ids = [
        aws_security_group.my_security_group.id
      ]
    }
  }

  tags = {
    Environment = "dev"
    Project     = "eks-devops"
  }
}

output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}