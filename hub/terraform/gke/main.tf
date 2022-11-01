variable "name" {
  default = "onify-demo"
}
variable "gce_project_id" {
  default = "onify-forge"
}
variable "gce_region" {
  default = "europe-north1"
}

variable "gke_username" {
  default     = ""
  description = "gke username"
}

variable "gke_password" {
  default     = ""
  description = "gke password"
}

variable "gke_num_nodes" {
  default     = 1
  description = "number of gke nodes"
}

terraform {
  backend "gcs" {
    bucket = "onify-demo-terraform"
    prefix = "terraform/state/onify-demo"
  }
}

module "gcs" {
  source           = "github.com/onify//terraform//modules/gcs"
  name           = "${var.name}-terraform"
  gce_project_id = var.gce_project_id
}

module "gke" {
  source           = "github.com/onify/terraform//modules/gke"
  name           = var.name
  gce_project_id = var.gce_project_id
  gce_region     = var.gce_region
  gke_num_nodes  = var.gke_num_nodes
  gke_username   = var.gke_username
  gke_password   = var.gke_password
}
