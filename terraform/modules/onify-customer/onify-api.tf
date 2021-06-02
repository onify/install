resource "kubernetes_secret" "onify-api" {
  metadata {
    name      = "${var.client}-onify-api"
    namespace = var.client
  }
  data = {
    admin_password   = var.onify-api_admin_password
    app_token_secret = var.onify-api_app_token
    client_secret    = var.onify-api_client_secret
  }
  type = "Opaque"
}

resource "kubernetes_config_map" "onify-api" {
  metadata {
    name      = "${var.client}-onify-api"
    namespace = var.client
  }

  data = {
    NODE_ENV                    = "production"
    ENV_PREFIX                  = "ONIFY_"
    INTERPRET_CHAR_AS_DOT       = "_"
    ONIFY_db_elasticsearch_host = "http://${var.client}-elasticsearch:9200"
    ONIFY_db_indexPrefix        = "onify" # indices will be prefixed with this string
    ONIFY_client_code           = var.onify-api_client_code
    ONIFY_client_instance       = var.onify-api_instance
    ONIFY_initialLicense        = var.onify-api_license
    ONIFY_adminUser_username    = "admin"
    ONIFY_adminUser_email       = "admin@onify.local"
    ONIFY_resources_baseDir     = "/usr/share/onify/resources"
    ONIFY_resources_tempDir     = "/usr/share/onify/temp_resources"
    ONIFY_websockets_agent_url  = "ws://onify-agent-${var.client}:8080/hub"
  }
}

resource "kubernetes_stateful_set" "onify-api" {
  metadata {
    name      = "onify-api-${var.client}"
    namespace = var.client
    labels = {
      app  = "onify-api-${var.client}"
      name = "onify-api-${var.client}"
    }
  }
  spec {
    service_name = "onify-api-${var.client}"
    volume_claim_template {
      metadata {
        name      = "data-onify-api-${var.client}"
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
        app  = "onify-api-${var.client}"
        task = "onify-api-${var.client}"
      }
    }
    template {
      metadata {
        labels = {
          app  = "onify-api-${var.client}"
          task = "onify-api-${var.client}"
        }
      }
      spec {
        image_pull_secrets {
          name = "onify-regcred"
        }
        container {
          image = "eu.gcr.io/onify-images/hub/api:${var.onify-api_version}"
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
            name           = "onify-api"
            container_port = 8181
          }
          env_from {
            config_map_ref {
              name = "${var.client}-onify-api"
            }
          }
          env {
            name  = "ONIFY_autoinstall"
            value = true
          }
          env {
            name = "ONIFY_adminUser_password"
            value_from {
              secret_key_ref {
                name = "${var.client}-onify-api"
                key  = "admin_password"
              }
            }
          }
          env {
            name = "ONIFY_apiTokens_app_secret"
            value_from {
              secret_key_ref {
                name = "${var.client}-onify-api"
                key  = "app_token_secret"
              }
            }
          }
          env {
            name = "ONIFY_client_secret"
            value_from {
              secret_key_ref {
                name = "${var.client}-onify-api"
                key  = "client_secret"
              }
            }
          }
          volume_mount {
            name       = "data-onify-api-${var.client}"
            mount_path = "/usr/share/onify"
          }
        }
      }
    }
  }
  depends_on = [kubernetes_namespace.client]
}

resource "kubernetes_service" "onify-api" {
  metadata {
    name      = "onify-api-${var.client}"
    namespace = var.client
    annotations = {
      "cloud.google.com/load-balancer-type" = "Internal"
    }
  }
  spec {
    selector = {
      app  = "onify-api-${var.client}"
      task = "onify-api-${var.client}"
    }
    port {
      name     = "onify-api"
      port     = 8181
      protocol = "TCP"
    }
    type = "NodePort"
    //type = "LoadBalancer"
  }
  depends_on = [kubernetes_namespace.client]
}
