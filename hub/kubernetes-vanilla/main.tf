/*
provider "kubernetes" {
  config_path = "~/.kube/config"
  config_context = "gke_onify-forge_europe-north1-a_onify-demo-gke"
}
*/

variable "client_code" {
    default = "xxx" // Contact your local partner or support@onify.co to get this information
}
variable "client_instance" {
    default = "xxx" // Contact your local partner or support@onify.co to get this information
}

module "onify" {
  source                          = "git::git@github.com:onify/install//terraform/modules/kubernetes-vanilla"
  gcr_registry_keyfile            = "./keyfile.json" // Contact your local partner or support@onify.co to get this information
  onify_api_envs                  = {
    ONIFY_client_code             = var.client_code
    ONIFY_client_instance         = var.client_instance
    ONIFY_initialLicense          = "xxx" // Contact your local partner or support@onify.co to get this information
    ONIFY_adminUser_password      = "xxx"
    ONIFY_apiTokens_app_secret    = "xxx"
    ONIFY_client_secret           = "xxx"
    ONIFY_db_elasticsearch_host   = "http://onify-${var.client_code}-${var.client_instance}:9200"
    ONIFY_websockets_agent_url    = "ws://onify-${var.client_code}-${var.client_instance}-agent:8080/hub"
  }
  onify_app_envs                    = {
    ONIFY_api_externalUrl       = "/api/v2"
    ONIFY_disableAdminEndpoints = false
    ONIFY_api_admintoken        = "xx"
    ONIFY_api_internalUrl       = "onify-${var.client_code}-${var.client_instance}-api:8181/api/v2"
  }
}
