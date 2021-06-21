resource "kubernetes_stateful_set" "onify-worker" {
  metadata {
    name      = "${var.onify_client_code}-${var.onify_instance}-onify-worker"
    namespace = "${var.onify_client_code}-${var.onify_instance}"
    labels = {
      app  = "${var.onify_client_code}-${var.onify_instance}-onify-worker"
      name = "${var.onify_client_code}-${var.onify_instance}-onify-worker"
    }
  }
  spec {
    service_name = "${var.onify_client_code}-${var.onify_instance}-onify-worker"
    replicas     = var.deployment_replicas
    selector {
      match_labels = {
        app  = "${var.onify_client_code}-${var.onify_instance}-onify-worker"
        task = "${var.onify_client_code}-${var.onify_instance}-onify-worker"
      }
    }
    template {
      metadata {
        labels = {
          app  = "${var.onify_client_code}-${var.onify_instance}-onify-worker"
          task = "${var.onify_client_code}-${var.onify_instance}-onify-worker"
        }
      }
      spec {
        image_pull_secrets {
          name = "onify-regcred"
        }
        container {
          image = "eu.gcr.io/onify-images/hub/api:${var.onify-worker_version}"
          name  = "onfiy-api"
          resources {
            limits = {
              cpu    = var.cpu_limit
              memory = var.memory_limit
            }
            requests = {
              cpu    = var.cpu_requests
              memory = var.memory_requests
            }
          }
          port {
            name           = "onify-worker"
            container_port = 8181
          }
          args = ["worker"]
          env_from {
            config_map_ref {
              name = "${var.onify_client_code}-${var.onify_instance}-onify-api"
            }
          }
          env {
            name  = "ONIFY_worker_cleanupInterval"
            value = 300
          }
          env {
            name = "ONIFY_adminUser_password"
            value_from {
              secret_key_ref {
                name = "${var.onify_client_code}-${var.onify_instance}-onify-api"
                key  = "admin_password"
              }
            }
          }
          env {
            name = "ONIFY_apiTokens_app_secret"
            value_from {
              secret_key_ref {
                name = "${var.onify_client_code}-${var.onify_instance}-onify-api"
                key  = "app_token_secret"
              }
            }
          }
          env {
            name = "ONIFY_client_secret"
            value_from {
              secret_key_ref {
                name = "${var.onify_client_code}-${var.onify_instance}-onify-api"
                key  = "client_secret"
              }
            }
          }
        }
      }
    }

  }
  depends_on = [kubernetes_namespace.client]
}
