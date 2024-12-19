# EKS cluster setup with Karpenter and Graviton on AWS

This repository contains Terraform code to deploy an EKS cluster with Karpenter for autoscaling, utilizing both x86 and arm64 instances.

## Usage

For deploying of AWS EKS Cluster with Karpenter you should execute next commands in subdirectory "terraform/":

1. **Initialize Terraform**:
```sh
terraform init
```

2. **Plan the Infrastructure**: 
```sh
terraform plan
```

3. **Apply the Configuration**:
```sh
terraform apply
```

## How to Run a Pod on Specific Architecture

To run a pod on a specific architecture (x86 or arm64), you can use node selectors in your Kubernetes deployment manifest.

### Example for x86:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: x86-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: my-x86-app
  template:
    metadata:
      labels:
        app: my-x86-app
    spec:
      containers:
      - name: my-container
        image: my-x86-image
      nodeSelector:
        kubernetes.io/arch: amd64
```

### Example for arm64:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: arm64-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: my-arm64-app
  template:
    metadata:
      labels:
        app: my-arm64-app
    spec:
      containers:
      - name: my-container
        image: my-arm64-image
      nodeSelector:
        kubernetes.io/arch: arm64
```

This setup should allow Karpenter to manage the nodes for your EKS cluster dynamically, providing both x86 and arm64 instances as needed. If there are any additional requirements or configurations needed, adjust the Terraform code accordingly.



