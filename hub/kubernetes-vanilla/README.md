# Onify vanilla installation on Kubernetes 

Terraform boilerplate for setting up Onify in Kubernetes without storage and ingress.
This is just an example to get all containers up and running in a k8s environment.

> IMPORTANT: You also need to attach storage to Elasticsearch and configure the ingress for other services, see [containers](/containers.md) for more information.

## Prerequisites

1. A working kubernetes installation. Terraform will apply Onify against the default kubernetes context. Override by setting ```export KUBE_CONFIG_PATH=kubeconfig_file```

2. A gcr registry file containing credentials to download the onify gcr images

> Note: It is recommended to use a remote backend for terraform state.

## Setup 

1. `terraform init`
2. `terraform plan`
3. `terraform apply`

## Testing

Use port forwarding to test the app and login with username and password.

`kubectl port-forward --address localhost pod/onify-app-0 3000:3000 -n onify-{CLIENT CODE}-{INSTANCE CODE}`
