#  Provision Onify using terraform

# Global prerequisites
terraform binary


All examples use local terraform state. It´s recommended to use a remote storage to store terraform state. The [gcs](.gcs) module can be use to create a gcs bucket and terraform can be configured to use that bucket for remote state. Example code:
```code
terraform {
  backend "gcs" {
    bucket = "k8s-example-terraform"
    prefix = "terraform/state/k8s-example"
  }
}
```


## [gcs](./gcs)
#### <strong>prerequisites</strong>: gcloud configured and a keyfile with access to gcr container registry
Example that will provision a google cloud storage bucket.

## [gce](./gce)
#### <strong>prerequisites</strong>: gcloud configured and a keyfile with access to gcr container registry

Example that will provision a linux machine in google cloud with microk8s and with onify.
Add your ssh pub key i main.tf to be able to access the machine after installation.
"domain" is the DNS zone you will be using. 

1. ```terraform apply --target=module.gce```
2. ```KUBE_CONFIG_PATH=kubeconfig_${var.name} terraform apply --target=module.onify```


## [gke](.gke)
#### <strong>prerequisites</strong>: gcloud configured
Example that will provision gke in google cloud with onify

## [kubernetes](./kubernetes)
#### <strong>prerequisites</strong>: Access to a k8s cluster.
Example that will provision onify on a kubernetes cluster.
Terraform will use the default context. 

1. ```KUBE_CONFIG_PATH=kubeconfig_example terraform apply```