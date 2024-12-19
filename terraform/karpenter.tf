module "iam_assumable_role_karpenter" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "5.43.0"
  create_role                   = true
  role_name                     = "karpenter-controller-${var.env}-${var.aws_region}"
  provider_url                  = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  oidc_fully_qualified_subjects = ["system:serviceaccount:karpenter:karpenter"]
}

resource "aws_iam_role_policy" "karpenter_contoller" {
  name = "karpenter-policy-${var.env}-${var.aws_region}"
  role = module.iam_assumable_role_karpenter.iam_role_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:CreateLaunchTemplate",
          "ec2:CreateFleet",
          "ec2:RunInstances",
          "ec2:CreateTags",
          "iam:PassRole",
          "ec2:TerminateInstances",
          "ec2:DeleteLaunchTemplate",
          "ec2:DescribeLaunchTemplates",
          "ec2:DescribeInstances",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeInstanceTypeOfferings",
          "ec2:DescribeAvailabilityZones",
          "ssm:GetParameter"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

data "aws_iam_policy" "ssm_managed_instance" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "karpenter_ssm_policy" {
  role       = module.iam_assumable_role_karpenter.iam_role_name
  policy_arn = data.aws_iam_policy.ssm_managed_instance.arn
}

resource "aws_iam_instance_profile" "karpenter" {
  name = "KarpenterNodeInstanceProfile-${var.cluster_name}"
  role = module.iam_assumable_role_karpenter.iam_role_name
}

resource "kubernetes_namespace" "karpenter" {
  metadata {
    name = "karpenter"
  }
}

resource "helm_release" "karpenter" {
  namespace = "karpenter"

  name       = "karpenter"
  repository = "oci://public.ecr.aws/karpenter"
  chart      = "karpenter"
  version    = "0.36.0"

  set {
    name  = "serviceAccount.annotations.eks.amazonaws.com/role-arn"
    value = module.iam_assumable_role_karpenter.iam_role_arn
  }

  set {
    name  = "clusterName"
    value = var.cluster_name
  }

  set {
    name  = "clusterEndpoint"
    value = module.eks.cluster_endpoint
  }
  set {
    name  = "aws.defaultInstanceProfile"
    value = aws_iam_instance_profile.karpenter.name
  }

  timeout = 600

  depends_on = [
    kubernetes_namespace.karpenter
  ]
}

# # Karpenter provisioner for x86 instances
resource "kubernetes_manifest" "karpenter_provisioner_x86" {
  manifest = {
    apiVersion = "karpenter.sh/v1alpha5"
    kind       = "Provisioner"
    metadata = {
      name = "default-x86"
    }
    spec = {
      requirements = [
        {
          key      = "kubernetes.io/arch"
          operator = "In"
          values   = ["amd64"]
        }
      ]
      limits = {
        resources = {
          cpu    = "1000"
          memory = "2000Gi"
        }
      }
      provider = {
        amiFamily = "AL2"
        instanceTypes = [
          "t3a.nano",
          "t3a.micro",
          "t3a.small",
        ]
      }
      ttlSecondsAfterEmpty = 30
    }
  }
}

# # Karpenter provisioner for arm64 instances
resource "kubernetes_manifest" "karpenter_provisioner_arm64" {
  manifest = {
    apiVersion = "karpenter.sh/v1alpha5"
    kind       = "Provisioner"
    metadata = {
      name = "default-arm64"
    }
    spec = {
      requirements = [
        {
          key      = "kubernetes.io/arch"
          operator = "In"
          values   = ["arm64"]
        }
      ]
      limits = {
        resources = {
          cpu    = "1000"
          memory = "2000Gi"
        }
      }
      provider = {
        amiFamily = "AL2"
        instanceTypes = [
          "r8g.medium",
          "r8g.large",
          "r8g.xlarge",
        ]
      }
      ttlSecondsAfterEmpty = 30
    }
  }
}


