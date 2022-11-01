

# I ALREADY HAVE A K8S CLUSTER I WOULD LIKE TO USE. THE K8S CLUSTER DON´T HAVE ANYTHING CONFIGURED FOR ONIFY

  ## IS THIS A LAB? = NO TERRAFORM 
  ## DO YOU ALREADY HAVE A TERRAFORM REMOTE BACKEND 

# I ALREADY HAVE A K8S CLUSTER I WOULD LIKE TO USE. THE K8S CLUSTER HAVE THE BASE INFRA WITH TRAEFIK AND EXTERNAL-DNS

# I DON´T HAVE A K8S CLUSTER BUT WOULD LIKE TO HAVE A GKE CLUSTER AND A ONIFY PLATFORM

# I DON´T HAVE A K8S CLUSTER BUT WOULD LIKE TO HAVE ONE HOSTED ON A LINUX MACHINE I GCP






## Set up Onify using a google cloud compone engine instance and microk8s

## 1
Edit the "name" variable to your project name and also edit google project id etc.
run ```terraform init```

## 2
This step is only needed if we would like the terraform state to be stored remote (which is highly recommended). But in a local dev environment it can be skipped and terraform state will be store locally. 
In this example we will create a gcs bucket which the terraform state would be stored at. But lot´s of other remote backends can be used see this link for other examples:
https://www.terraform.io/language/settings/backends#available-backends

To create a gcs bucket use this run ```terraform apply -target="module.gcs"``` to create a google cloud storage bucket for terraform state files
Press yes to create the bucket.
## 3
Uncomment this code in main.tf:
```sh
# # CAN ONLY BE USED IF MODULE GCS EXISTS
terraform {
  backend "gcs" {
    bucket = "MYPROJECT-terraform"
    prefix = "terraform/state/MYPROJECT"
  }
}
```
## 4
Run ```terraform init``` again and answer "yes" to to copy this state to the new "gcs

Backend all set.

## 5
To create a onify platform on gce the infrastructure is split in 3 pieces.
  - google compute instance
  - onify base infrastructure (kubernetes manifests)
  - onify platform (kubernetes manifests)

There´s a work in progress so not everything can be applied at once by using ```sh terraform apply`. So individual pieces can be deployed using.

Right now we need to create the pieces individually 

#### 1
```terraform apply -target="module.gce"```
This will create a google compute instance which installs microk8s. After deployment is complete a kubeconfig file will be placed in the working directory. This can then be used by typing ```KUBECONFIG=kubeconfig_file kubectl get pods```
If this command works you´re all set for the next step. 

#### 2 
Apply the base infrastructure needed for onify by typing.
```terraform apply -target="module.onify-infrastructure"```
In main.tf there´s a kubernetes provider block that use the kubeconfig file created in the module.gce module.

#### 3
Apply onify platform by typing
```terraform apply --target="module.onify-client"```
In main.tf there´s a kubernetes provider block that use the kubeconfig file created in the module.gce module.

Onify will be available at ```app.MYPROJECT.onify.io```

KNOWN BUGS:
terraform destroy --target="module.onify-client" hangs because a persistent volume claim can´t be removed. It´s not removed automatically in the currect k8s version (latest not supported yet) so the pvc must be removed manually by typing ```kubectl delete pvc PVCNAME -n PROJECTNAMESPACE```