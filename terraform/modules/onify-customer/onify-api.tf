resource "kubernetes_secret" "onify-api" {
  metadata {
    name      = "${var.onify_client_code}-${var.onify_instance}-onify-api"
    namespace = "${var.onify_client_code}-${var.onify_instance}"
  }
  data = {
    admin_password   = var.onify-api_admin_password
    app_token_secret = var.onify-api_secret
    client_secret    = var.onify-api_client_secret
  }
  type = "Opaque"
}

resource "kubernetes_config_map" "onify-api" {
  metadata {
    name      = "${var.onify_client_code}-${var.onify_instance}-onify-api"
    namespace = "${var.onify_client_code}-${var.onify_instance}"
  }

  data = {
    NODE_ENV                    = "production"
    ENV_PREFIX                  = "ONIFY_"
    INTERPRET_CHAR_AS_DOT       = "_"
    ONIFY_db_elasticsearch_host = var.elasticsearch_address != null ? var.elasticsearch_address : "http://${var.onify_client_code}-${var.onify_instance}-elasticsearch:9200"
    ONIFY_db_indexPrefix        = "onify" # indices will be prefixed with this string
    ONIFY_client_code           = var.onify_client_code
    ONIFY_client_instance       = var.onify_instance
    ONIFY_initialLicense        = var.onify-api_license
    ONIFY_adminUser_username    = "admin"
    ONIFY_adminUser_email       = "admin@onify.local"
    ONIFY_resources_baseDir     = "/usr/share/onify/resources"
    ONIFY_resources_tempDir     = "/usr/share/onify/temp_resources"
    ONIFY_websockets_agent_url  = "ws://onify-agent-${var.onify_client_code}-${var.onify_instance}:8080/hub"
  }
}

resource "kubernetes_stateful_set" "onify-api" {
  metadata {
    name      = "${var.onify_client_code}-${var.onify_instance}-onify-api"
    namespace = "${var.onify_client_code}-${var.onify_instance}"
    labels = {
      app  = "${var.onify_client_code}-${var.onify_instance}-onify-api"
      name = "${var.onify_client_code}-${var.onify_instance}-onify-api"
    }
  }
  spec {
    service_name = "${var.onify_client_code}-${var.onify_instance}-onify-api"
    replicas     = var.deployment_replicas
    selector {
      match_labels = {
        app  = "${var.onify_client_code}-${var.onify_instance}-onify-api"
        task = "${var.onify_client_code}-${var.onify_instance}-onify-api"
      }
    }
    template {
      metadata {
        labels = {
          app  = "${var.onify_client_code}-${var.onify_instance}-onify-api"
          task = "${var.onify_client_code}-${var.onify_instance}-onify-api"
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
              name = "${var.onify_client_code}-${var.onify_instance}-onify-api"
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

resource "kubernetes_service" "onify-api" {
  metadata {
    name      = "${var.onify_client_code}-${var.onify_instance}-onify-api"
    namespace = "${var.onify_client_code}-${var.onify_instance}"
    annotations = {
      "cloud.google.com/load-balancer-type" = "Internal"
    }
  }
  spec {
    selector = {
      app  = "${var.onify_client_code}-${var.onify_instance}-onify-api"
      task = "${var.onify_client_code}-${var.onify_instance}-onify-api"
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


resource "kubernetes_ingress" "onify-api" {
  count                  = var.onify-api_external ? 1 : 0
  wait_for_load_balancer = false
  metadata {
    name      = "${var.onify_client_code}-${var.onify_instance}-onify-api"
    namespace = "${var.onify_client_code}-${var.onify_instance}"

    # labels = {
    #   loadbalancer = "traefik"
    # }
  }
  spec {
    rule {
      host = "${var.onify_client_code}-${var.onify_instance}-api.onify.io"
      http {
        path {
          backend {
            service_name = "${var.onify_client_code}-${var.onify_instance}-onify-api"
            service_port = 8181
          }
        }
      }
    }
  }
  depends_on = [kubernetes_namespace.client]
}
