# EKS Platform Engineering

End-to-end Terraform configuration for provisioning a production-ready EKS cluster on AWS, complete with all the platform add-ons you actually need to run workloads — external-dns, external-secrets-operator, cluster-autoscaler, KEDA, and ArgoCD.

Split into two separate Terraform roots so cluster infrastructure and add-ons can evolve independently without stepping on each other.

## Structure

```
eks-platform-engineering/
├── terraform/
│   ├── cluster/        # EKS cluster, node groups, VPC, IAM
│   └── addons/         # Helm-based platform add-ons
└── docs/
    └── architecture.md
```

## Prerequisites

- AWS account + credentials configured (`aws configure` or role assumption)
- Terraform >= 1.5.0
- `kubectl`
- `helm` v3+

## Usage

### Step 1 — Provision the cluster

```bash
cd terraform/cluster
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
terraform init
terraform plan
terraform apply
```

This creates the VPC, subnets, EKS control plane, and managed node groups.

### Step 2 — Install platform add-ons

```bash
cd terraform/addons
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values (cluster name, region, domain, etc.)
terraform init
terraform plan
terraform apply
```

This installs all cluster add-ons via Helm.

### Step 3 — Connect kubectl

```bash
aws eks update-kubeconfig \
  --region <your-region> \
  --name <your-cluster-name>
```

## What gets installed

| Add-on | Purpose |
|--------|---------|
| external-dns | Syncs K8s Ingress/Service hostnames to Route53 |
| external-secrets-operator | Pulls secrets from AWS Secrets Manager into K8s |
| cluster-autoscaler | Scales node groups up/down based on pod demand |
| KEDA | Event-driven pod autoscaling (SQS, Kafka, custom metrics) |
| AWS Load Balancer Controller | Provisions ALBs and NLBs for Ingress/Service resources |
| ArgoCD | GitOps controller for continuous delivery |

## Remote state

Both Terraform roots share state in S3 with DynamoDB locking. The `addons` root reads cluster outputs (endpoint, CA cert, OIDC URL) from the `cluster` state file using a remote state data source — no manual copy-pasting.

Update the bucket and table names in `main.tf` before running:

```hcl
backend "s3" {
  bucket         = "your-terraform-state-bucket"
  key            = "eks/cluster/terraform.tfstate"
  region         = "us-east-1"
  dynamodb_table = "terraform-state-lock"
  encrypt        = true
}
```

## Node groups

The cluster ships with two node groups:

- **system** — small On-Demand instances for system pods (CoreDNS, add-ons)
- **application** — mixed On-Demand + Spot instances for workloads

Adjust sizes and instance types in `terraform.tfvars`.

## IAM and security

- IRSA (IAM Roles for Service Accounts) is used for all add-ons — no static credentials
- Cluster endpoint is private by default; public access is opt-in via `cluster_endpoint_public_access`
- Node IAM roles follow least-privilege
