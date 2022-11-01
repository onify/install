// Store Terraform state in Google Cloud Storage and not locally
terraform {
  backend "gcs" {
    bucket = "onify-terraform-state" // Bucket where to store state (needs to exist)
    prefix = "client-instance/<CLIENT CODE>-<INSTANCE CODE>" // Folder where to store state ("client-code + '-' + instance-code" is recommended)
  }
}

// Kubernetes cluster to use and auth 
provider "kubernetes" {
  config_path = "~/.kube/config" // Run "gcloud container clusters get-credentials <CLUSTER> --region <REGION>" to generate
  config_context = "<CLUSTER>" // Context to use. Check .kube/config file.
}

module "onify-client-instance" {
  source = "github.com/onify/terraform//modules/onify-customer" // Source for Terraform modules
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

  ssl_staging = true // Letencrypt staging API or not
    
  // -- Onify Agent --
  //onify-agent_external = true // Creates ingress with external access
  onify-agent_version = "latest" // Image version
  onify-agent_memory_limit = "10m"
  onify-agent_cpu_limit = "10mi"
  onify-agent_memory_requests = "10m"
  onify-agent_cpu_requests = "10mi"
  
  // -- Onify API --
  //onify-api_external = true // Creates ingress with external access
  onify-api_version = "latest" // Image version
  onify-api_memory_limit = "10m"
  onify-api_cpu_limit = "10mi"
  onify-api_memory_requests = "10m"
  onify-api_cpu_requests = "10mi"

  // -- Onify Worker --
  onify-worker_version = "latest" // Image version
  onify-worker_memory_limit = "10m"
  onify-worker_cpu_limit = "10mi"
  onify-worker_memory_requests = "10m"
  onify-worker_cpu_requests = "10mi"
  
  // -- Onify APP --
  onify-app_version = "latest" // Image version
  onify-app_memory_limit = "10m"
  onify-app_cpu_limit = "10mi"
  onify-app_memory_requests = "10m"
  onify-app_cpu_requests = "10mi"
  
  // -- Elasticsearch --
  //elasticsearch_version = "7.16.1"
  elasticsearch_heapsize = "1g" // set ES_JAVA_OPTS 
  elasticsearch_disksize = "20Gi"
  //elasticsearch_address = "http://elasticcloud.example.something:9200" //do not create elasticsearch
  //elasticsearch_memory_limit = "10m"
  //elasticsearch_cpu_limit = "10mi"
  //elasticsearch_memory_requests = "10m"
  //elasticsearch_cpu_requests = "10mi"
}
