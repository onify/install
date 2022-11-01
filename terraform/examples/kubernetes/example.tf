

### IF A REMOTE BACKEND IS USED
# terraform {
#   backend "gcs" {
#     bucket = "k8s-example-terraform"
#     prefix = "terraform/state/k8s-example"
#   }
# }

### YOUR DEFAULT KUBECONFIG AND CURRENT CONTEXT WILL BE USED. OVERRIDE BY CHOOSING A KUBECONFIG FILE§
# provider "kubernetes" {
#   experiments {
#     manifest_resource = true
#   }
#   config_path    = "kubeconfig_${var.name}"
# }


module "onify-infrastructure" {
  source                = "git::git@github.com:onify/install//terraform/modules/onify-infrastructure"
  external-dns-domain   = "k8s-example.onify.io"
  gce_project_id        = var.gce_project_id
  traefik-image_version = "2.6.1"
  traefik-log_level     = "INFO"
  gke                   = false
}

module "onify-client" {
  source                         = "git::git@github.com:onify/install//terraform/modules/onify-customer"
  gcr_registry_keyfile            = "/path/keyfile.json"
  external-dns-domain             = "k8s-example.onify.io"
  # onify-agent_version             = "latest"
  # onify-agent_memory_limit      = "100m"
  # onify-agent_cpu_limit         = "100Mi"
  # onify-agent_memory_requests   = "100m"
  # onify-agent_cpu_requests      = "100Mi"
  # onify-api_external            =  true // creates ingress with external access
  # onify-api_version             = "latest"
  # onify-api_memory_limit        = "100m"
  # onify-api_cpu_limit           = "100Mi"
  # onify-api_memory_requests     = "100m"
  # onify-api_cpu_requests        = "100Mi"
  # onify-worker_version          = "latest"
  # onify-worker_memory_limit     = "100m"
  # onify-worker_cpu_limit        = "100Mi"
  # onify-worker_memory_requests  = "100m"
  # onify-worker_cpu_requests     = "100Mi"
  # onify-app_version             = "latest"
  # onify-app_memory_limit        = "100m"
  # onify-app_cpu_limit           = "100Mi"
  # onify-app_memory_requests     = "100m"
  # onify-app_cpu_requests        = "100Mi"
  # elasticsearch_address         = "http://elasticcloud.example.something:9200" // if set we dont create a elasticsearch instance
  # lasticsearch_memory_requests = "2Gi"
  elasticsearch_memory_limit      = "2Gi"
  elasticsearch_heapsize          = "1500m" // set ES_JAVA_OPTS
  elasticsearch_disksize          = "2Gi"
  gke                             = false  // Only creates a local persistence volume. Set false for virtual machines (gce)
  onify_agent_envs                = {
    "log_level" = "1"
    "log_type" = "1"
    "hub_version" = "v2"
  }
  onify_api_envs                  = {
    NODE_ENV                      = "production"
    ENV_PREFIX                    = "ONIFY_"
    INTERPRET_CHAR_AS_DOT         = "_"
    ONIFY_db_indexPrefix          = "onify" # indices will be prefixed with this string
    ONIFY_adminUser_username      = "admin"
    ONIFY_adminUser_email         = "admin@onify.local"
    ONIFY_resources_baseDir       = "/usr/share/onify/resources"
    ONIFY_resources_tempDir       = "/usr/share/onify/temp_resources"
    ONIFY_autoinstall             = true
    ONIFY_client_code             = var.name
    ONIFY_client_instance         = "demo1"
    ONIFY_initialLicense          = "xx"
    ONIFY_adminUser_password      = "xx"
    ONIFY_apiTokens_app_secret    = "xx"
    ONIFY_client_secret           = "xx"
  }
  onify_app_envs                    = {
    NODE_ENV                      = "production"
    ENV_PREFIX                    = "ONIFY_"
    INTERPRET_CHAR_AS_DOT         = "_"
    ONIFY_api_externalUrl         = "/api/v2"
    ONIFY_disableAdminEndpoints   = true
    ONIFY_api_admintoken          = "xx" 
  }
  onify_worker_envs               = {
    ONIFY_adminUser_password      = "xx"
    ONIFY_apiTokens_app_secret    = "xx"
    ONIFY_worker_cleanupInterval  = 300
    ONIFY_client_secret           = "xx"
  }
}
