resource "helm_release" "argocd_image_updater" {
  name      = "argocd-image-updater"
  namespace = "argocd"

  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argocd-image-updater"

  set {
    name = "config.registries"
    value = <<EOF
- name: Docker Hub
  api_url: https://registry-1.docker.io
  prefix: docker.io
EOF
  }

  depends_on = [helm_release.argocd]
}