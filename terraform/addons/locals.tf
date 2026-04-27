locals {
  cluster_name     = data.terraform_remote_state.cluster.outputs.cluster_name
  oidc_provider_arn = data.terraform_remote_state.cluster.outputs.oidc_provider_arn
}
