module "external_dns_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name                     = "${local.cluster_name}-external-dns"
  attach_external_dns_policy    = true
  external_dns_hosted_zone_arns = ["arn:aws:route53:::hostedzone/*"]

  oidc_providers = {
    main = {
      provider_arn               = local.oidc_provider_arn
      namespace_service_accounts = ["external-dns:external-dns"]
    }
  }
}

resource "helm_release" "external_dns" {
  name             = "external-dns"
  repository       = "https://kubernetes-sigs.github.io/external-dns/"
  chart            = "external-dns"
  version          = var.external_dns_chart_version
  namespace        = "external-dns"
  create_namespace = true

  values = [
    yamlencode({
      provider    = "aws"
      domainFilters = [var.domain_name]
      txtOwnerId  = local.cluster_name

      serviceAccount = {
        annotations = {
          "eks.amazonaws.com/role-arn" = module.external_dns_irsa_role.iam_role_arn
        }
      }

      policy = "sync"
    })
  ]
}
