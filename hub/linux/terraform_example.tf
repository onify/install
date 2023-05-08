// Kubernetes cluster to use and auth
provider "kubernetes" {
  config_path = "kubeconfig"
}

module "onify" {
  source = "github.com/onify/terraform//modules/onify-customer"
  gcr_registry_keyfile            = "./keyfile.json" // Contact your local partner or support@onify.co to get this information
  external-dns-domain           = "onify.example.domain" //results in clientcode-clientinstance-app.onify.ioforce.se for example
  
  onify_api_envs                  = {
    NODE_ENV                    = "production"
    ENV_PREFIX                  = "ONIFY_"
    INTERPRET_CHAR_AS_DOT       = "_"
    ONIFY_db_indexPrefix        = "onify" # indices will be prefixed with this string
    ONIFY_adminUser_username    = "admin"
    ONIFY_adminUser_email       = "admin@onify.local"
    ONIFY_resources_baseDir     = "/usr/share/onify/resources"
    ONIFY_resources_tempDir     = "/usr/share/onify/temp_resources"
    ONIFY_autoinstall   = true
    ONIFY_client_code             = "XXXX"
    ONIFY_client_instance         = "XXXX"
    ONIFY_initialLicense          = "XXXX"
    ONIFY_adminUser_password      = "XXXX"
    ONIFY_apiTokens_app_secret    = "XXXX"
    ONIFY_client_secret           = "XXXX"
    ONIFY_worker_cleanupInterval = "300"
  }
  onify_app_envs                    = {
    NODE_ENV              = "production"
    ENV_PREFIX            = "ONIFY_"
    INTERPRET_CHAR_AS_DOT = "_"
    ONIFY_api_admintoken        = "Bearer XXX"
    ONIFY_api_externalUrl       = "/api/v2"
    ONIFY_disableAdminEndpoints = false
  }
  gke = false
  elasticsearch_heapsize = "256m"
  tls = "onify-custom"
}
