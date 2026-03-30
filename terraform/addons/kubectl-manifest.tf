#####################################
# ARGOCD PROJECTS
#####################################
resource "kubectl_manifest" "argocd_projects" {
  for_each = fileset("${path.module}/../../argocd", "project.yaml")

  yaml_body = file("${path.module}/../../argocd/${each.value}")

  depends_on = [helm_release.argocd]
}

#####################################
# ARGOCD APPLICATIONS
#####################################
resource "kubectl_manifest" "argocd_apps" {
  for_each = fileset("${path.module}/../../argocd", "applicationset.yaml")

  yaml_body = file("${path.module}/../../argocd/${each.value}")

  depends_on = [kubectl_manifest.argocd_projects]
}