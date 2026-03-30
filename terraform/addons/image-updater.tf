resource "null_resource" "argocd_image_updater" {

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]

    command = <<EOT
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj-labs/argocd-image-updater/v0.12.2/manifests/install.yaml
kubectl rollout status deployment/argocd-image-updater -n argocd --timeout=120s
EOT
  }

  depends_on = [
    helm_release.argocd,
    kubernetes_secret_v1.argocd_git_creds
  ]
}