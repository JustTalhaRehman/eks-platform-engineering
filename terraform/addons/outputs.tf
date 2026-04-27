output "external_dns_role_arn" {
  description = "IAM role ARN for external-dns"
  value       = module.external_dns_irsa_role.iam_role_arn
}

output "external_secrets_role_arn" {
  description = "IAM role ARN for external-secrets-operator"
  value       = module.external_secrets_irsa_role.iam_role_arn
}

output "cluster_autoscaler_role_arn" {
  description = "IAM role ARN for cluster-autoscaler"
  value       = module.cluster_autoscaler_irsa_role.iam_role_arn
}
