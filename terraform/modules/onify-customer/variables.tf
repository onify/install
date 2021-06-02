variable "client" {
    type = string
}

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
variable "onify-api_client_code" {}
variable "onify-api_instance" {}
variable "onify-api_license" {}
