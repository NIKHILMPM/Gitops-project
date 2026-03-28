resource "kubernetes_secret_v1" "dockerhub_creds" {
  metadata {
    name      = "dockerhub-secret"
    namespace = "argocd"
  }

  type = "kubernetes.io/dockerconfigjson"

  data = {
    ".dockerconfigjson" = base64encode(jsonencode({
      auths = {
        "https://index.docker.io/v1/" = {
          username = var.dockerhub_username
          password = var.dockerhub_token
          auth     = base64encode("${var.dockerhub_username}:${var.dockerhub_token}")
        }
      }
    }))
  }

  depends_on = [
    helm_release.argocd
  ]
}