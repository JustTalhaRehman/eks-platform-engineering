resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = var.argocd_chart_version
  namespace        = "argocd"
  create_namespace = true

  values = [
    yamlencode({
      global = {
        domain = "argocd.${var.domain_name}"
      }

      server = {
        ingress = {
          enabled          = true
          ingressClassName = "alb"
          annotations = {
            "alb.ingress.kubernetes.io/scheme"      = "internal"
            "alb.ingress.kubernetes.io/target-type" = "ip"
          }
        }
      }

      configs = {
        params = {
          "server.insecure" = true
        }
      }
    })
  ]
}
