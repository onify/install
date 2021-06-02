
variable "name" {}

variable "gce_project_id" {
  description = "google cloud project id"
}

variable "gce_region" {
  description = "google cloud region"
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