resource "helm_release" "argocd-image-udpater" {
  name = "argocd-image-updater"

  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argocd-image-updater"
  namespace        = "argocd"
  create_namespace = true

  values = [file("values/argocd-image-updater.yaml")]
}

