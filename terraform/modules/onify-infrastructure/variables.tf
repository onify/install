variable "gce_project_id" {
  description = "google cloud project id"
}
variable "external-dns-domain" {}
variable "traefik-image_version" {}
variable "traefik-log_level" {
  default = "ERROR"
}