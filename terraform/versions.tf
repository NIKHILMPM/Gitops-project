terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    kubernetes = {
      source = "hashicorp/kubernetes"
    }

    helm = {
      source = "hashicorp/helm"
    }

    kubectl = {
      source = "gavinbunney/kubectl"
      version = ">= 1.14.0"
    }
  }
}
