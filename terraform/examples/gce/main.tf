variable "name" {
  default = "k8s-example"
}
variable "gce_project_id" {
  default = "onify-forge"
}
variable "gce_region" {
  default = "europe-north1"
}
variable "gce_zone" {
  default = "europe-north1-a"
}

#CREATE BACKEND
module "gcs" {
  source            = "github.com/onify/terraform//modules/gcs"
  name              = "${var.name}-terraform"
  gce_project_id    = "onify-forge"
}

### CAN ONLY BE USED IF MODULE GCS EXISTS
terraform {
  backend "gcs" {
    bucket = "k8s-example-terraform"
    prefix = "terraform/state/k8s-example"
  }
}

module "gce" {
  source           = "github.com/onify/terraform//modules/gce"
  name              = var.name
  gce_project_id    = var.gce_project_id
  gce_region        = var.gce_region
  gce_zone          = var.gce_zone
  domain            = "onify.io"
  machine_type      = "e2-standard-4"
  //os_image          = "ubuntu-os-cloud/ubuntu-2004-lts"
  //disk_size         = "30"
  //disk_type         = "pd-standard|pd-balances|pd-ssd"
  ssh_keys = [
      {
        user = "ubuntu"
        publickey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOM0Z44gsOiiM5642Qm0RxTAfnHCTr/oSMN9S8jYMHAW"
      }
    ]
}

provider "kubernetes" {
  experiments {
    manifest_resource = true
  }
  config_path    = "kubeconfig_${var.name}"
}
