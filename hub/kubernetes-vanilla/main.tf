variable "client_code" {
}
variable "client_instance" {
}

module "onify" {
  source                         = "git::git@github.com:onify/install//terraform/modules/kubernetes-vanilla"
  gcr_registry_keyfile            = "~/repos/onify/keyfile.json"
  onify_api_envs                  = {
    ONIFY_client_code             = var.client_code
    ONIFY_client_instance         = var.client_instance
    ONIFY_initialLicense          = "xxx"
    ONIFY_adminUser_password      = "xxx"
    ONIFY_apiTokens_app_secret    = "xxx"
    ONIFY_client_secret           = "xxx"
  }
  onify_app_envs                    = {
    ONIFY_api_externalUrl         = "/api/v2"
    ONIFY_disableAdminEndpoints   = true
    ONIFY_api_admintoken          = "xxx"
  }
  onify_worker_envs               = {
    ONIFY_worker_cleanupInterval  = 30
  }
}
