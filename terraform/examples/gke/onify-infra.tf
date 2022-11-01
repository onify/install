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
module "onify-infrastructure" {
  source           = "github.com/onify/terraform//modules/onify-infrastructure"
  external-dns-domain = "onify.io"
  gce_project_id      = var.gce_project_id
  traefik_version     = "2.4.8"
}
