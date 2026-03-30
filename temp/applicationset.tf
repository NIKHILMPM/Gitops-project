resource "kubernetes_manifest" "applicationset" {
  manifest = yamldecode(<<YAML
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: chat-app-set
  namespace: argocd

spec:
  generators:
    - list:
        elements:
          - name: mongodb
            path: helm/mongodb
            namespace: chat-app
            wave: "0"
            image: mongo

          - name: backend
            path: helm/backend
            namespace: chat-app
            wave: "1"
            image: ramachandrampm/chat-app-backend

          - name: frontend
            path: helm/frontend
            namespace: chat-app
            wave: "2"
            image: ramachandrampm/chat-app-frontend

  template:
    metadata:
      name: "chatapp-{{name}}"
      annotations:
        argocd.argoproj.io/sync-wave: "{{wave}}"

        argocd-image-updater.argoproj.io/image-list: "{{name}}={{image}}"
        argocd-image-updater.argoproj.io/{{name}}.update-strategy: semver
        argocd-image-updater.argoproj.io/{{name}}.allow-tags: regexp:^v[0-9]+\.[0-9]+\.[0-9]+$

        argocd-image-updater.argoproj.io/write-back-method: git:secret:argocd/argocd-image-updater-git-creds

    spec:
      project: chatapp-project

      source:
        repoURL: https://github.com/NIKHILMPM/Gitops-project.git
        targetRevision: main
        path: "{{path}}"
        helm: {}

      destination:
        server: https://kubernetes.default.svc
        namespace: "{{namespace}}"

      syncPolicy:
        automated:
          prune: true
          selfHeal: true
        syncOptions:
          - CreateNamespace=true
YAML
  )

  depends_on = [
    kubernetes_manifest.appproject,
    helm_release.argocd_image_updater
  ]
}
