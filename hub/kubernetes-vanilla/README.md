# Onify vanilla installation on kubernetes 

## Prerequisites

1. A working kubernetes installation. Terraform will apply Onify against the default kubernetes context. Override by setting ```export KUBECONFIG=anotherKubernetes```

2. Terraform variables ```client_code``` and ```client_instance``` must be set either directly in main.tf or by exporting environmental variables  ```TF_VAR_client_code=company TF_VAR_client_instance=demo terraform apply```
3. A gc registry file containing credentials to download the onify gcr images

Use kubeproxy to access onify application.

It is recommended to use a remote backend for terraform state.


