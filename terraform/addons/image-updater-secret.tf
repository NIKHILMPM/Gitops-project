resource "kubernetes_secret" "argocd_git_creds" {
  metadata {
    name      = "argocd-image-updater-git-creds"
    namespace = "argocd"
  }

  data = {
    username = base64encode(var.github_username)
    password = base64encode(var.github_token)
  }

  type = "Opaque"

  depends_on = [
    helm_release.argocd,
    module.eks
  ]
}