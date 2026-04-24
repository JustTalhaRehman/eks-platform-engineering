locals {
  azs = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    Environment = var.environment
    Cluster     = var.cluster_name
  }
}
