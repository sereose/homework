resource "aws_iam_role" "nodes" {
  name = "eks-node-group"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role" "arm64_nodes" {
  name = "arm64-node-group"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "amazon-eks-worker-node-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.nodes.name
}

resource "aws_iam_role_policy_attachment" "amazon-eks-worker-node-policy_arm64" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.arm64_nodes.name
}

resource "aws_iam_role_policy_attachment" "amazon-eks-cni-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.nodes.name
}

resource "aws_iam_role_policy_attachment" "amazon-eks-cni-policy_arm64" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.arm64_nodes.name
}

resource "aws_iam_role_policy_attachment" "amazon-ec2-container-registry-read-only" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.nodes.name
}

resource "aws_iam_role_policy_attachment" "amazon-ec2-container-registry-read-only_arm64" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.arm64_nodes.name
}

resource "aws_eks_node_group" "amd64-nodes" {
  cluster_name    = aws_eks_cluster.cluster.name
  version         = "1.30"
  node_group_name = "amd64-nodes"
  node_role_arn   = aws_iam_role.nodes.arn

  subnet_ids = [
    aws_subnet.private-us-east-1a.id,
    aws_subnet.private-us-east-1b.id
  ]

  capacity_type  = "spot"
  instance_types = ["t3.medium"]
  arch = "amd64"

  scaling_config {
    desired_size = 1
    max_size     = 10
    min_size     = 0
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    role = "general"
  }

  depends_on = [
    aws_iam_role_policy_attachment.amazon-eks-worker-node-policy,
    aws_iam_role_policy_attachment.amazon-eks-cni-policy,
    aws_iam_role_policy_attachment.amazon-ec2-container-registry-read-only,
  ]

  # Allow external changes without Terraform plan difference
  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }
}

resource "aws_eks_node_group" "arm64-nodes" {
  cluster_name    = aws_eks_cluster.cluster.name
  version         = "1.30"
  node_group_name = "arm64-nodes"
  node_role_arn   = aws_iam_role.arm64_nodes.arn

  subnet_ids = [
    aws_subnet.private-us-east-1a.id,
    aws_subnet.private-us-east-1b.id
  ]

  capacity_type  = "spot"
  instance_types = ["t3.medium"]
  arch = "arm64"

  scaling_config {
    desired_size = 1
    max_size     = 10
    min_size     = 0
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    role = "general"
  }

  depends_on = [
    aws_iam_role_policy_attachment.amazon-eks-worker-node-policy_arm64,
    aws_iam_role_policy_attachment.amazon-eks-cni-policy_arm64,
    aws_iam_role_policy_attachment.amazon-ec2-container-registry-read-onl_arm64y,
  ]

  # Allow external changes without Terraform plan difference
  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }
}