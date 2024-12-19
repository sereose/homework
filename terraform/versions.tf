terraform {
  required_version = "~> 1.9.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.31.0"
    }
    kubectl = {
      source  = "alekc/kubectl"
      version = "2.0.4"
    }
    helm = {
      source = "hashicorp/helm"
      version = "2.14.0"
    }
  }

  # Store Terraform State file on S3 bucket and use DynamoDB for State locking
  # to prevent concurrent changes which can lead to inconsistency of infrastructure
  #  backend "s3" {
  #    region         = var.region
  #    encrypt        = true
  #    key            = "..."
  #    bucket         = "..."
  #    dynamodb_table = "..."
  #  }
}
