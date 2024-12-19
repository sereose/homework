variable "aws_region" {
  description = "The AWS region to deploy to"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
  default     = "my-eks-cluster"
}

variable "cluster_version" {
  description = "The version of the EKS cluster"
  type        = string
  default     = "1.30"
}

variable "env" {
  type        = string
  default     = "test"
}

variable "generic_tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {
    Environment = "test"
    Owner       = "Kirils Curilovs"
  }
}
