resource "helm_release" "keda" {
  name             = "keda"
  repository       = "https://kedacore.github.io/charts"
  chart            = "keda"
  version          = var.keda_chart_version
  namespace        = "keda"
  create_namespace = true

  values = [
    yamlencode({
      serviceAccount = {
        operator = {
          annotations = {
            "eks.amazonaws.com/role-arn" = module.keda_irsa_role.iam_role_arn
          }
        }
      }
    })
  ]
}

module "keda_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name = "${local.cluster_name}-keda"

  role_policy_arns = {
    # KEDA needs to read SQS queue lengths, CloudWatch metrics, etc.
    # Scope this down to only the queues/metrics you actually scale on.
    AmazonSQSReadOnlyAccess = "arn:aws:iam::aws:policy/AmazonSQSReadOnlyAccess"
  }

  oidc_providers = {
    main = {
      provider_arn               = local.oidc_provider_arn
      namespace_service_accounts = ["keda:keda-operator"]
    }
  }
}
