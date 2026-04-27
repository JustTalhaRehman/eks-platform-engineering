# Architecture

## Two Terraform roots, one cluster

The configuration is split into two independent Terraform state files to avoid provider chicken-and-egg problems and allow independent change cycles.

```
terraform/
├── cluster/   ← provisions VPC, EKS control plane, node groups
└── addons/    ← installs Helm charts on top of the cluster
```

The `addons` root reads cluster outputs from remote state. No manual variable passing.

## IRSA — IAM Roles for Service Accounts

Every add-on that needs AWS API access (external-dns, external-secrets, cluster-autoscaler, KEDA) gets its own dedicated IAM role. The role is bound to a specific Kubernetes service account via OIDC federation — no static credentials anywhere.

```
Pod → ServiceAccount → IAM Role → AWS API
         (OIDC token)    (scoped permissions)
```

## Node groups

| Node Group | Capacity | Purpose |
|------------|----------|---------|
| system     | On-Demand | CoreDNS, add-on pods, tolerates CriticalAddonsOnly taint |
| application | Spot (mixed) | Workload pods, scaled by cluster-autoscaler |

## Networking

- VPC with public + private subnets across 3 AZs
- NAT Gateway per environment (single for non-prod, one per AZ for prod)
- EKS control plane in private subnets only
- ALB Ingress via AWS Load Balancer Controller
