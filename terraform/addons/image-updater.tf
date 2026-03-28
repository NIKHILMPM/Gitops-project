resource "null_resource" "argocd_image_updater" {

  provisioner "local-exec" {
    command = <<EOT
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj-labs/argocd-image-updater/v0.12.2/manifests/install.yaml
EOT
  }

  depends_on = [
    helm_release.argocd,
    kubernetes_secret.argocd_git_creds
  ]
}