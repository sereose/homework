# AWS EKS Cluster
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.20.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_id  = data.aws_vpc.default.id

  subnet_ids = data.aws_subnets.default.ids

  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  authentication_mode = "API_AND_CONFIG_MAP"

  # add default minimal node group
  eks_managed_node_group_defaults = {
    disk_size      = 50
    instance_types = ["t3a.medium"]
  }

  eks_managed_node_groups = {
    default = {
      desired_capacity = 2
      min_size         = 1
      max_size         = 4
    }
  }

  tags = var.generic_tags
}

