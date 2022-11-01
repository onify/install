variable "client_code" {
    default = "example" // Contact your local partner or support@onify.co to get this information
}
variable "client_instance" {
    default = "demo" // Contact your local partner or support@onify.co to get this information
}

module "onify" {
  source                          = "github.com/onify/terraform//modules/kubernetes-vanilla"
  gcr_registry_keyfile            = "./keyfile.json" // Contact your local partner or support@onify.co to get this information
  onify_api_envs                  = {
    ONIFY_client_code             = var.client_code
    ONIFY_client_instance         = var.client_instance
    ONIFY_initialLicense          = "xxx"
    ONIFY_adminUser_password      = "xxx"
    ONIFY_apiTokens_app_secret    = "xxx"
    ONIFY_client_secret           = "xxx"
    ONIFY_db_elasticsearch_host   = "http://elasticsearch:9200"
    ONIFY_websockets_agent_url    = "ws://onify-agent:8080/hub"
  }
  onify_app_envs                    = {
    ONIFY_api_admintoken        = "xxx"
    ONIFY_api_externalUrl       = "/api/v2"
    ONIFY_api_internalUrl       = "http://onify-api:8181/api/v2"
    ONIFY_disableAdminEndpoints = false
  }
}
