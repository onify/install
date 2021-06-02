resource "kubernetes_stateful_set" "onify-worker" {
  metadata {
    name      = "onify-worker-${var.client}"
    namespace = var.client
    labels = {
      app  = "onify-worker-${var.client}"
      name = "onify-worker-${var.client}"
    }
  }
  spec {
    service_name = "onify-worker-${var.client}"
    volume_claim_template {
      metadata {
        name      = "data-onify-worker-${var.client}"
        namespace = var.client
      }
      spec {
        access_modes = ["ReadWriteOnce"]
        #storage_class_name = "standard" //could be "ssd" for faster disks
        resources {
          requests = {
            storage = "10Gi"
          }
        }
      }
    }
    replicas = var.deployment_replicas
    selector {
      match_labels = {
        app  = "onify-worker-${var.client}"
        task = "onify-worker-${var.client}"
      }
    }
    template {
      metadata {
        labels = {
          app  = "onify-worker-${var.client}"
          task = "onify-worker-${var.client}"
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
              name = "${var.client}-onify-worker"
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
                name = "${var.client}-onify-worker"
                key  = "admin_password"
              }
            }
          }
          env {
            name = "ONIFY_apiTokens_app_secret"
            value_from {
              secret_key_ref {
                name = "${var.client}-onify-worker"
                key  = "app_token_secret"
              }
            }
          }
          env {
            name = "ONIFY_client_secret"
            value_from {
              secret_key_ref {
                name = "${var.client}-onify-worker"
                key  = "client_secret"
              }
            }
          }
          volume_mount {
            name       = "data-onify-worker-${var.client}"
            mount_path = "/usr/share/onify"
          }
        }
      }
    }
  }
  depends_on = [kubernetes_namespace.client]
}
