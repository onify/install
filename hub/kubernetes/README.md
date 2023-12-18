
# Install Onify on Kubernetes

To simplify the installation on Kubernetes we are currently using [Terraform](https://www.terraform.io/). You can checkout our [Terraform modules](https://github.com/onify/terraform/tree/main). 

## Prerequisites

### Kubernetes

You need to have a Kubernetes cluster (container platform) up and running, like [Google Kubernetes Engine (GKE)](https://cloud.google.com/kubernetes-engine), [Red Hat OpenShift](https://www.redhat.com/en/technologies/cloud-computing/openshift) or [Azure Kubernetes Service (AKS)](https://azure.microsoft.com/en-us/products/kubernetes-service) or [MicroK8s](https://microk8s.io/) (Linux machine). 

### Access to container images

You need access to the Onify Hub container images located at Google Container Registry (`eu.gcr.io`). For this you need a `keyfile.json`. Please contact `support@onify.co` for more info.

You might also need access to GitHub Container Registry (`ghcr.io`). You need a username and a personal access token (PAT) for this.

### Linux and MicroK8s

Installing Onify Hub on a single Linux machine requires MicroK8s and Terraform. Here is script to set everything up:

```bash
curl -L https://raw.githubusercontent.com/onify/install/default/hub/kubernetes/install_microk8s.sh | bash
```

## Installation

1. Create a `.tf` Terraform file (see `setup.example.tf`)
2. Create a `.tfvars` file for Terraform variables (see `setup.example.tfvars`)
3. Run `terraform init` to download and initialize Onify Terraform modules
4. Run `terraform plan` to plan Onify infrastructure (optional)
5. Run `terraform apply` to apply Onify infrastructure

### Custom TLS

You can add your own custom cert instead of default [Let's Encrypt](https://letsencrypt.org/). Create a Kubernetes secret manifest file container certificate and key. Here is an example:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: onify-custom 
  namespace: default
type: kubernetes.io/tls
data:
  tls.crt: <base64-encoded-certificate>
  tls.key: <base64-encoded-private-key>
```

Then you need to apply the secret with: 
```bash
kubectl apply -f custom_tls_example.yaml
```

And set the `tls` variable in the `.tf` file:
```tf
tls = "onify-custom"
```

## Troubleshooting

### kubeconfig

You might need to run `export KUBECONFIG=kubeconfig` to get `kubectl` working. 

### kubectl port-forward

Use port forwarding to test the app and login with username and password.

```bash
kubectl port-forward --address localhost pod/onify-app-0 3000:3000 -n onify-{CLIENT CODE}-{INSTANCE CODE}
```
