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


# # CAN ONLY BE USED IF MODULE GCS EXISTS
terraform {
  backend "gcs" {
    bucket = "onify-demo-terraform"
    prefix = "terraform/state/onify-demo"
  }
}

module "gcs" {
  #source           = "git::git@github.com:onify/install/terraform/modules/gcs"
  source         = "./terraform/modules/gcs"
  name           = "${var.name}-terraform"
  gce_project_id = var.gce_project_id
}

module "gke" {
  #source           = "git::git@github.com:onify/install/terraform/modules/gke"
  source         = "./terraform/modules/gke"
  name           = var.name
  gce_project_id = var.gce_project_id
  gce_region     = var.gce_region
  gke_num_nodes  = 4
  gke_username   = var.gke_username
  gke_password   = var.gke_password
}

module "onify-infrastructure" {
  #source           = "git::git@github.com:onify/install/terraform/modules/onify-infrastructure"
  source                = "./terraform/modules/onify-infrastructure"
  external-dns-domain   = "onify.io"
  gce_project_id        = var.gce_project_id
  traefik-image_version = "2.4.8"
  traefik-log_level     = "ERROR"
}

module "onify-client-whoami" {
  #source           = "git::git@github.com:onify/install/terraform/modules/onify-customer"
  source               = "./terraform/modules/onify-customer"
  gcr_registry_keyfile = "~/repos/onify/keyfile.json"
  onify_client_code    = "whoami"
  onify_instance       = "demo1"
  //onify-agent_external     = true // creates ingress with external access
  onify-agent_version         = "latest"
  onify-agent_memory_limit    = "10m"
  onify-agent_cpu_limit       = "10mi"
  onify-agent_memory_requests = "10m"
  onify-agent_cpu_requests    = "10mi"
  //onify-api_external       = true // creates ingress with external access
  onify-api_admin_password     = "#!"
  onify-api_app_token          = "Yfgdfgdfgfdg"
  onify-api_client_secret      = "Ffdgfdgdgfdg="
  onify-api_secret             = "dfgdfgdfgdfge"
  onify-api_license            = "eyJhdfgdfgdfgpZW50XdfgdfgfdgXQiOjE2MTIydfgdfgdf"
  onify-api_version            = "latest"
  onify-api_memory_limit       = "10m"
  onify-api_cpu_limit          = "10mi"
  onify-api_memory_requests    = "10m"
  onify-api_cpu_requests       = "10mi"
  onify-worker_version         = "latest"
  onify-worker_memory_limit    = "10m"
  onify-worker_cpu_limit       = "10mi"
  onify-worker_memory_requests = "10m"
  onify-worker_cpu_requests    = "10mi"
  onify-app_version            = "latest"
  onify-app_memory_limit       = "10m"
  onify-app_cpu_limit          = "10mi"
  onify-app_memory_requests    = "10m"
  onify-app_cpu_requests       = "10mi"
  //elasticsearch_address    = "http://elasticcloud.example.something:9200" //do not create elasticsearch
  elasticsearch_memory_limit    = "10m"
  elasticsearch_cpu_limit       = "10mi"
  elasticsearch_memory_requests = "10m"
  elasticsearch_cpu_requests    = "10mi"
  //elasticsearch_heapsize        = "1g" // set ES_JAVA_OPTS
  elasticsearch_disksize = "10Gi"
}


data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${module.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}
