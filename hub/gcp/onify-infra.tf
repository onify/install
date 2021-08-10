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

# # CAN ONLY BE USED IF MODULE GCS EXISTS
terraform {
  backend "gcs" {
    bucket = "onify-demo-terraform"
    prefix = "terraform/state/onify-demo"
  }
}

module "gcs" {
  source           = "github.com/onify/install//terraform/modules/gcs"
  name           = "${var.name}-terraform"
  gce_project_id = var.gce_project_id
}

module "gke" {
  source           = "github.com/onify/install//terraform/modules/gke"
  name           = var.name
  gce_project_id = var.gce_project_id
  gce_region     = var.gce_region
  gke_num_nodes  = var.gke_num_nodes
  gke_username   = var.gke_username
  gke_password   = var.gke_password
}

module "onify-infrastructure" {
  source           = "github.com/onify/install//terraform/modules/onify-infrastructure"
  external-dns-domain = "onify.io"
  gce_project_id      = var.gce_project_id
  traefik_version     = "2.4.8"
}

module "onify-client-example" {
  source           = "github.com/onify/install//terraform/modules/onify-customer"
  client                   = "example"
  gcr_registry_keyfile     = "~/repos/onify/keyfile.json"
  onify-agent_version      = "latest"
  onify-api_admin_password = base64encode("password")
  onify-api_app_token      = base64encode("Bearer password")
  onify-api_client_secret  = base64encode("password")
  onify-api_secret         = base64encode("password")
  onify_client_code    = "client"
  onify_instance       = "demo123"
  onify-api_license        = "licenseXXXX"
  onify-api_version        = "latest"
  onify-worker_version     = "latest"
  onify-app_version        = "latest"
}

data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${module.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}