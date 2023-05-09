Install Onify Hub in Linux
==========================

Installing Onify Hub on a single Linux machine requires [Microk8s](https://microk8s.io/), terraform.


1. Install Microk8s and terraform

2. (OPTIONAL: For custom TLS certifcate)

3. Install Onify


1a. Install and configure microk8s and terraform with:
```
curl -L https://raw.githubusercontent.com/onify/install/default/hub/linux/install_microk8s.sh | bash
```

> Note: You might need to run `export KUBECONFIG=kubeconfig` to get `kubectl` working. 

2a. Custom TLS
1. Create a kubernetes secret manifest file container certificate and key. Example in repo.

2. apply secret with:
  ```kubectl apply -f custom_tls_example.yaml```

3. set variable
```tls = "onify-custom"``` in terraform.tf at step 3


3a. Install Onify with terraform

1. Create a `terraform.tf` terraform file (example in this repo)
  _create a keyfile.json with credentials to pull onify images. (Needed to pull images from containerregistry)_

2. Run ```terraform init``` to download Onify terraform modules

3. Run ```terraform apply``` to apply Onify infrastructure

