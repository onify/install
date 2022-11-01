module "onify-infrastructure" {
  source                = "github.com/onify/terraform//modules/onify-infrastructure"
  external-dns-domain   = "${var.name}.onify.io"
  gce_project_id        = var.gce_project_id
  traefik-image_version = "2.6.1"
  traefik-log_level     = "INFO"
  gke                   = false
}
