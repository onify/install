## Set up Onify using a google cloud compone engine instance and microk8s

# FIRST TIME
## 1
run ```sh terraform apply -target="module.gcs"``` to create a google cloud storage bucket for terraform state files

## 2
Uncomment this code:
```sh
# # CAN ONLY BE USED IF MODULE GCS EXISTS
terraform {
  backend "gcs" {
    bucket = "MYPROJECT-terraform"
    prefix = "terraform/state/MYPROJECT"
  }
}
```

## 3
Run ```sh terraform init``` again and answer "yes" to to copy this state to the new "gcs

All set.
You can now run ```sh terraform apply``` to create a onify platform


## 4