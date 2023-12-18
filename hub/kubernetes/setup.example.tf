### IF A REMOTE BACKEND IS USED FOR TERRAFORM STATE
# terraform {
#   backend "gcs" {
#     bucket = "terraform"
#     prefix = "state/k8s-example"
#   }
# }

### YOUR DEFAULT KUBECONFIG AND CURRENT CONTEXT WILL BE USED. OVERRIDE BY CHOOSING A KUBECONFIG FILE
# provider "kubernetes" {
#   experiments {
#     manifest_resource = true
#   }
#   config_path = "kubeconfig"
#   config_path    = "kubeconfig_${var.name}"
#   config_path    = "~/.kube/config"
#   config_context = "gke_onify-forge_europe-north1-a_infra-internal-gke"
# }

# DEFINE VARIABLES (.tfvars)
variable "ghcr_registry_username" {}
variable "ghcr_registry_password" {}
variable "onify_api_license" {}
variable "onify_api_admin_username" {}
variable "onify_api_admin_password" {}
variable "onify_api_app_secret" {}
variable "onify_api_client_secret" {}
variable "onify_app_api_admin_token" {}

module "onify-client-instance" {
  source                 = "github.com/onify/terraform//modules/onify-customer-helix"
  elasticsearch_external = false
  ghcr_registry_username = var.ghcr_registry_username
  ghcr_registry_password = var.ghcr_registry_password
  gcr_registry_keyfile   = "./keyfile.json"
  elasticsearch_heapsize = "1g" # The more the better
  external-dns-domain    = "onify.net"
  custom_hostname        = ["dev"] # Array of domain names
  onify-helix_image      = "ghcr.io/onify/helix-app-lab:latest"
  onify_api_envs = {
    #DEBUG                              = "bpmn-engine:error*" # See https://support.onify.co/discuss/65251b6009eaa20a104adba2
    NODE_ENV                           = "production"
    ENV_PREFIX                         = "ONIFY_"
    INTERPRET_CHAR_AS_DOT              = "_"
    ONIFY_db_indexPrefix               = "onify"
    ONIFY_adminUser_email              = "admin@onify.local"
    ONIFY_resources_baseDir            = "/usr/share/onify/resources"
    ONIFY_resources_tempDir            = "/usr/share/onify/temp_resources"
    ONIFY_autoinstall                  = true
    ONIFY_client_code                  = "oni"
    ONIFY_client_instance              = "dev"
    ONIFY_initialLicense               = var.onify_api_license
    ONIFY_adminUser_username           = var.onify_api_admin_username
    ONIFY_adminUser_password           = var.onify_api_admin_password
    ONIFY_apiTokens_app_secret         = var.onify_api_app_secret
    ONIFY_client_secret                = var.onify_api_client_secret
    #ONIFY_worker_cleanupInterval       = "300"
    #ONIFY_logging_logLevel             = "debug" # Default is "info"
    ONIFY_logging_log                  = "stdout" # Or "stdout,elastic"
    #ONIFY_logging_elasticFlushInterval = "500"
  }
  onify_app_envs = {
    NODE_ENV                    = "production"
    ENV_PREFIX                  = "ONIFY_"
    INTERPRET_CHAR_AS_DOT       = "_"
    ONIFY_api_admintoken        = var.onify_app_api_admin_token
    ONIFY_api_externalUrl       = "/api/v2"
    #ONIFY_disableAdminEndpoints = true
  }
  #gke = true # Running Google Kubernetes Engine
  tls                        = "prod" # Letencrypt staging or prod. Can also be set to custom, eg. "onify-custom"
  #kubernetes_node_api_worker = "gke-infra-internal-g-infra-internal-g-d6d3672e-051b"
}
