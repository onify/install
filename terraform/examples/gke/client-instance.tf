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
  gcr_registry_keyfile = "./keyfile.json" // Path to keyfile to access container images in GCR

  onify_client_code = "<CLIENT CODE>" // ENV = ONIFY_client_code
  onify_instance = "<INSTANCE CODE>" // ENV = ONIFY_client_instance
  onify-api_admin_password = "<ADMIN PASSWORD>" // ENV = ONIFY_adminUser_password
  onify-api_app_token = "Bearer <API ADMIN TOKEN>" // ENV = ONIFY_api_admintoken
  onify-api_client_secret = "<CLIENT SECRET>" // ENV = ONIFY_client_secret
  onify-api_secret = "<API ADMIN APP SECRET>" // ENV = ONIFY_apiTokens_app_secret
  onify-api_license = "<ONIFY LICENSE>" // ENV = ONIFY_initialLicense
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
