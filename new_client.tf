# # CAN ONLY BE USED IF MODULE GCS EXISTS
terraform {
  backend "gcs" {
    bucket = "onify-demo-terraform"
    prefix = "terraform/state/onify-client-acme"
  }
}

module "onify-client-acme" {
  #source           = "git::git@github.com:onify/install//terraform/modules/onify-customer?ref=terraform"
  source               = "./terraform/modules/onify-customer"
  gcr_registry_keyfile = "./keyfile.json"
  onify_client_code    = "acme"
  onify_instance       = "demo1"
  //onify-agent_external     = true // creates ingress with external access
  onify-agent_version         = "latest"
  onify-agent_memory_limit    = "10m"
  onify-agent_cpu_limit       = "10mi"
  onify-agent_memory_requests = "10m"
  onify-agent_cpu_requests    = "10mi"
  //onify-api_external       = true // creates ingress with external access
  onify-api_admin_password     = "<ADMIN_PASSWORD>"
  onify-api_app_token          = "<APP_API_TOKEN>"
  onify-api_client_secret      = "<API_CLIENT_SECRET>"
  onify-api_secret             = "<API_APP_SECRET>"
  onify-api_license            = "<LICENSE>"
  onify-api_version            = "latest"
  onify-api_memory_limit       = "10m"
  onify-api_cpu_limit          = "10mi"
  onify-api_memory_requests    = "10m"
  onify-api_cpu_requests       = "10mi"
  onify-worker_version         = "latest"
  onify-worker_memory_limit    = "10m"
  onify-worker_cpu_limit       = "10mi"
  onify-worker_memory_requests = "10m"
  onify-worker_cpu_requests    = "10mi"
  onify-app_version            = "latest"
  onify-app_memory_limit       = "10m"
  onify-app_cpu_limit          = "10mi"
  onify-app_memory_requests    = "10m"
  onify-app_cpu_requests       = "10mi"
  //elasticsearch_address    = "http://elasticcloud.example.something:9200" //do not create elasticsearch
  //elasticsearch_memory_limit    = "10m"
  //elasticsearch_cpu_limit       = "10mi"
  //elasticsearch_memory_requests = "10m"
  //elasticsearch_cpu_requests    = "10mi"
  //elasticsearch_heapsize        = "1g" // set ES_JAVA_OPTS
  elasticsearch_disksize = "20Gi"
}
