resource "kubernetes_secret" "argocd_git_creds" {
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