resource "helm_release" "vpa" {
  name      = "vpa"
  namespace = "kube-system"

  repository = "https://charts.fairwinds.com/stable"
  chart      = "vpa"

  depends_on = [helm_release.metrics_server]
}