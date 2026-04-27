data "aws_eks_cluster_auth" "this" {
  name = data.terraform_remote_state.cluster.outputs.cluster_name
}

# Pull cluster outputs without copy-pasting values
data "terraform_remote_state" "cluster" {
  backend = "s3"
  config = {
    bucket = "your-terraform-state-bucket"
    key    = "eks/cluster/terraform.tfstate"
    region = var.aws_region
  }
}
