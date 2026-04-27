module "external_secrets_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name                             = "${local.cluster_name}-external-secrets"
  attach_external_secrets_policy        = true
  external_secrets_secrets_manager_arns = ["arn:aws:secretsmanager:*:*:secret:*"]

  oidc_providers = {
    main = {
      provider_arn               = local.oidc_provider_arn
      namespace_service_accounts = ["external-secrets:external-secrets-sa"]
    }
  }
}

resource "helm_release" "external_secrets_operator" {
  name             = "external-secrets"
  repository       = "https://charts.external-secrets.io"
  chart            = "external-secrets"
  version          = var.external_secrets_chart_version
  namespace        = "external-secrets"
  create_namespace = true

  values = [
    yamlencode({
      serviceAccount = {
        name = "external-secrets-sa"
        annotations = {
          "eks.amazonaws.com/role-arn" = module.external_secrets_irsa_role.iam_role_arn
        }
      }
    })
  ]
}
