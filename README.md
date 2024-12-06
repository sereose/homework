# homework

Intro
In this homework, we're going to go over the following sections:

Cluster Autoscaller & Karpenter with two node pools arm64/amd64.
Create AWS VPC Using Terraform.
Create EKS Cluster Using Terraform.
Create Karpenter Controller IAM Role.
Deploy Karpenter to EKS
Create Karpenter Provisioner
Demo: Automatic Node Provisioning


Create AWS VPC Using Terraform
First of all, we need to create VPC using terraform.
Provider with some variables such as EKS cluster name and a region.
0-provider.tf


- VPC resource with EFS specific parameters.
1-vpc.tf

- Internet Gateway.
2-igw.tf

- Four subnets, two private and two public.
3-subnets.tf

- NAT Gateway.
4-nat.tf

- Finally two routes: one public with default route to internet gateway and a private with default route to NAT Gateway.
5-routes.tf

Let's initialize terraform and create all those components with terraform apply.
```bash
terraform init
terraform apply
```

- Create EKS Cluster Using Terraform¶
Next, we need to create an EKS cluster and a node group. EKS requires an IAM role to access AWS API on your behave to create resources.
6-eks.tf

- Now we need to create another IAM role for Kubernetes nodes.
7-nodes.tf

- Now let's again apply the terraform to create an EKS cluster.
```bash
terraform apply
```

- To connect to the cluster you need to update the Kubernetes context with this command.
```bash
aws eks update-kubeconfig --name demo --region us-east-1
```

- Then the quick check if we can reach Kubernetes. It should return the default k8s service.
```bash
kubectl get svc
```
- Create Karpenter Controller IAM Role¶
Karpenter needs permissions to create EC2 instances in AWS. If you use a self-hosted Kubernetes cluster, for example by using kOps. You can add additional IAM policies to the existing IAM role attached to Kubernetes nodes. We use EKS, the best way to grant access to internal service would be with IAM roles for service accounts.

First, we need to create an OpenID Connect provider.
8-iam-oidc.tf

- Next is a trust policy to allow the Kubernetes service account to assume the IAM role. Make sure that you deploy Karpenter to the karpenter namespace with the same service account name.
  9-karpenter-controller-role.tf
  
- Let's create the controller-trust-policy.json file.

controller-trust-policy.json

- Since we've added an additional provider we need to initialize before we can apply the terraform code.
```bash
terraform init
terraform apply
```

- Deploy Karpenter to EKS¶
To deploy Karpenter to our cluster, we're going to use Helm. First of all, you need to authenticate with EKS using the helm provider. Then the helm release.
10-karpenter-helm.tf

- Let's apply and check if the controller is running.
```bash
terraform init
terraform apply
```

- Check if the helm was deployed successfully. Then the karpenter pod in its dedicated namespace.
```bash
helm list -A
kubectl get pods -n karpenter
```

-  Create Karpenter Provisioner
Before we can test Karpenter, we need to create a Provisioner. Karpenter defines a Custom Resource called a Provisioner to specify provisioning configuration. Each provisioner manages a distinct set of nodes. You need to replace the demo with your EKS cluster name.
provisioner.yaml

- Finally, use kubectl to create those resources in the cluster.
```bash
kubectl apply -f k8s/provisioner.yaml
```

- Demo: Automatic Node Provisioning¶
Lastly, let's create a Kubernetes deployment to test how quickly Karpenter can create EC2 instances and schedule new pods.
./k8s/amd64-inflate-efficient.yaml.yaml
../k8s/arm64-inflate-efficient.yaml

- When you just getting started with Karpenter, it's a good idea to check logs in case you get any errors.
```bash
  kubectl logs -f -n karpenter \
-l app.kubernetes.io/name=karpenter
```
In another window, let's run get pods.
```bash
watch -n 1 -t kubectl get pods
```
Then let's get all the nodes available in the Kubernetes cluster.

```bash
watch -n 1 -t kubectl get nodes
```
