variable "cpu_limit" {
    default = "0.5"
}
variable "memory_limit" {
    default = "128Mi"
}
variable "cpu_requests" {
    default = "250m"
}
variable "memory_requests" {
    default = "50Mi"
}
variable "deployment_replicas" {
    default = 1
}
variable "gcr_registry_keyfile" {
}

variable "onify-agent_version" {
    default = "latest"
}
variable "onify-api_version" {
    default = "latest"
}
variable "onify-worker_version" {
    default = "latest"
}
variable "onify-app_version" {
    default = "latest"
}
variable "onify-api_admin_password" {}
variable "onify-api_app_token" {}
variable "onify-api_secret" {}
variable "onify-api_client_secret" {}
variable "onify_client_code" {}
variable "onify_instance" {}
variable "onify-api_license" {}
variable "onify-api_external" {
    default = false
}
variable "onify-agent_external" {
    default = false
}
variable "elasticsearch_address" {
    type = string
    default = null
}
variable "elasticsearch_heapsize" {
    type = string
    default = null
}
variable "elasticsearch_disksize" {
    default = "10Gi" 
}
variable "elasticsearch_memory_limit" {
    default = "1Gi"
}
variable "elasticsearch_memory_requests" {
    default = "1Gi"
}
variable "onify-api_memory_limit" {
    default = "10m"
}
variable "onify-api_cpu_limit" {
    default = "10mi"
}
variable "onify-api_memory_requests" {
    default = "10m"
}
variable "onify-api_cpu_requests" {
    default = "10m"
}
variable "onify-agent_memory_limit" {
    default = "10m"
}
variable "onify-agent_cpu_limit" {
    default = "10mi"
}
variable "onify-agent_memory_requests" {
    default = "10m"
}
variable "onify-agent_cpu_requests" {
    default = "10m"
}
variable "onify-worker_memory_limit" {
    default = "10m"
}
variable "onify-worker_cpu_limit" {
    default = "10mi"
}
variable "onify-worker_memory_requests" {
    default = "10m"
}
variable "onify-worker_cpu_requests" {
    default = "10m"
}
variable "onify-app_memory_limit" {
    default = "10m"
}
variable "onify-app_cpu_limit" {
    default = "10mi"
}
variable "onify-app_memory_requests" {
    default = "10m"
}
variable "onify-app_cpu_requests" {
    default = "10m"
}