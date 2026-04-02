#####################################
# METRICS SERVER
#####################################
resource "helm_release" "metrics_server" {
  name      = "metrics-server"
  namespace = "kube-system"

  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"

  wait             = true
  atomic           = true
  cleanup_on_fail  = true
  timeout          = 300
}

#####################################
# INGRESS
#####################################
resource "helm_release" "ingress" {
  name             = "ingress-nginx"
  namespace        = "ingress-nginx"
  create_namespace = true

  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"

  wait             = true
  atomic           = true
  cleanup_on_fail  = true
  timeout          = 400

  set = [
    {
      name  = "controller.admissionWebhooks.enabled"
      value = "false"
    }
  ]

  depends_on = [
    helm_release.metrics_server
  ]
}

#####################################
# ARGOCD
#####################################
resource "helm_release" "argocd" {
  name             = "argocd"
  namespace        = "argocd"
  create_namespace = true

  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"

  wait             = true
  atomic           = true
  cleanup_on_fail  = true
  timeout          = 600

  depends_on = [
    helm_release.ingress
  ]
}

#####################################
# ARGOCD SECRET
#####################################
resource "kubernetes_secret_v1" "argocd_git_creds" {
  metadata {
    name      = "argocd-image-updater-git-creds"
    namespace = "argocd"
  }

  data = {
    username = var.github_username
    password = var.github_token
  }

  type = "Opaque"

  depends_on = [
    helm_release.argocd
  ]
}

#####################################
# IMAGE UPDATER
#####################################
resource "null_resource" "argocd_image_updater" {
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]

    command = <<EOT
aws eks update-kubeconfig --region us-east-1 --name chatapp-eks-cluster

sleep 60

kubectl apply --validate=false -n argocd -f https://raw.githubusercontent.com/argoproj-labs/argocd-image-updater/v0.12.2/manifests/install.yaml 

kubectl rollout status deployment/argocd-image-updater -n argocd --timeout=180s
EOT
  }

  depends_on = [
    kubernetes_secret_v1.argocd_git_creds
  ]
}

#####################################
# VPA
#####################################
resource "helm_release" "vpa" {
  name      = "vpa"
  namespace = "kube-system"

  repository = "https://charts.fairwinds.com/stable"
  chart      = "vpa"

  wait             = true
  atomic           = true
  cleanup_on_fail  = true
  timeout          = 400

  depends_on = [
    null_resource.argocd_image_updater
  ]
}

#####################################
# MONITORING
#####################################
resource "helm_release" "monitoring" {
  name             = "kube-prometheus"
  namespace        = "monitoring"
  create_namespace = true

  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"

  wait             = true
  atomic           = true
  cleanup_on_fail  = true
  timeout          = 900

  depends_on = [
    helm_release.vpa
  ]
}

#####################################
# ARGOCD MANIFESTS
#####################################
resource "kubectl_manifest" "argocd_projects" {
  for_each = fileset("${path.module}/../../argocd", "project.yaml")

  yaml_body = file("${path.module}/../../argocd/${each.value}")

  depends_on = [
    helm_release.argocd
  ]
}

resource "kubectl_manifest" "argocd_apps" {
  for_each = fileset("${path.module}/../../argocd", "applicationset.yaml")

  yaml_body = file("${path.module}/../../argocd/${each.value}")

  depends_on = [
    kubectl_manifest.argocd_projects
  ]
}

