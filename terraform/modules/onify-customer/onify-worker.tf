resource "kubernetes_stateful_set" "onify-worker" {
  metadata {
    name      = "${var.onify_client_code}-${var.onify_instance}-worker"
    namespace = kubernetes_namespace.customer_namespace.metadata.0.name
    labels = {
      app  = "${var.onify_client_code}-${var.onify_instance}-worker"
      name = "${var.onify_client_code}-${var.onify_instance}-worker"
    }
  }
  spec {
    service_name = "${var.onify_client_code}-${var.onify_instance}-worker"
    replicas     = var.deployment_replicas
    selector {
      match_labels = {
        app  = "${var.onify_client_code}-${var.onify_instance}-worker"
        task = "${var.onify_client_code}-${var.onify_instance}-worker"
      }
    }
    template {
      metadata {
        labels = {
          app  = "${var.onify_client_code}-${var.onify_instance}-worker"
          task = "${var.onify_client_code}-${var.onify_instance}-worker"
        }
      }
      spec {
        image_pull_secrets {
          name = "onify-regcred"
        }
        container {
          image = "eu.gcr.io/onify-images/hub/api:${var.onify-worker_version}"
          name  = "onfiy-worker"
          resources {
            limits = {
              cpu    = var.onify-worker_cpu_limit
              memory = var.onify-worker_memory_limit
            }
            requests = {
              cpu    = var.onify-worker_cpu_requests
              memory = var.onify-worker_memory_requests
            }
          }
          port {
            name           = "onify-worker"
            container_port = 8181
          }
          args = ["worker"]
          env_from {
            config_map_ref {
              name = "${var.onify_client_code}-${var.onify_instance}-api"
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
                name = "${var.onify_client_code}-${var.onify_instance}-api"
                key  = "admin_password"
              }
            }
          }
          env {
            name = "ONIFY_apiTokens_app_secret"
            value_from {
              secret_key_ref {
                name = "${var.onify_client_code}-${var.onify_instance}-api"
                key  = "app_token_secret"
              }
            }
          }
          env {
            name = "ONIFY_client_secret"
            value_from {
              secret_key_ref {
                name = "${var.onify_client_code}-${var.onify_instance}-api"
                key  = "client_secret"
              }
            }
          }
        }
      }
    }
  }
  depends_on = [kubernetes_namespace.customer_namespace]
}
