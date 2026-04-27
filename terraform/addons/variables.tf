variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "domain_name" {
  description = "Base domain managed by Route53 (e.g. example.com)"
  type        = string
}

variable "argocd_chart_version" {
  description = "ArgoCD Helm chart version"
  type        = string
  default     = "7.3.11"
}

variable "external_dns_chart_version" {
  description = "external-dns Helm chart version"
  type        = string
  default     = "1.14.5"
}

variable "external_secrets_chart_version" {
  description = "external-secrets-operator Helm chart version"
  type        = string
  default     = "0.9.20"
}

variable "cluster_autoscaler_chart_version" {
  description = "cluster-autoscaler Helm chart version"
  type        = string
  default     = "9.36.0"
}

variable "keda_chart_version" {
  description = "KEDA Helm chart version"
  type        = string
  default     = "2.14.2"
}

variable "aws_lbc_chart_version" {
  description = "AWS Load Balancer Controller Helm chart version"
  type        = string
  default     = "1.8.1"
}
