resource "kubernetes_secret" "onify-api" {
  metadata {
    name      = "${var.onify_client_code}-${var.onify_instance}-api"
    namespace = kubernetes_namespace.customer_namespace.metadata.0.name
  }
  data = {
    admin_password   = var.onify-api_admin_password
    app_token_secret = var.onify-api_secret
    client_secret    = var.onify-api_client_secret
  }
  type = "Opaque"
  depends_on = [kubernetes_namespace.customer_namespace]
}

resource "kubernetes_config_map" "onify-api" {
  metadata {
    name      = "${var.onify_client_code}-${var.onify_instance}-api"
    namespace = kubernetes_namespace.customer_namespace.metadata.0.name
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
    ONIFY_websockets_agent_url  = "ws://${var.onify_client_code}-${var.onify_instance}-agent:8080/hub"
  }
  depends_on = [kubernetes_namespace.customer_namespace]
}

resource "kubernetes_stateful_set" "onify-api" {
  metadata {
    name      = "${var.onify_client_code}-${var.onify_instance}-api"
    namespace = kubernetes_namespace.customer_namespace.metadata.0.name
    labels = {
      app  = "${var.onify_client_code}-${var.onify_instance}-api"
      name = "${var.onify_client_code}-${var.onify_instance}-api"
    }
  }
  spec {
    service_name = "${var.onify_client_code}-${var.onify_instance}-api"
    replicas     = var.deployment_replicas
    selector {
      match_labels = {
        app  = "${var.onify_client_code}-${var.onify_instance}-api"
        task = "${var.onify_client_code}-${var.onify_instance}-api"
      }
    }
    template {
      metadata {
        labels = {
          app  = "${var.onify_client_code}-${var.onify_instance}-api"
          task = "${var.onify_client_code}-${var.onify_instance}-api"
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
              cpu    = var.onify-api_cpu_limit
              memory = var.onify-api_memory_limit
            }
            requests = {
              cpu    = var.onify-api_cpu_requests
              memory = var.onify-api_memory_requests
            }
          }
          port {
            name           = "onify-api"
            container_port = 8181
          }
          env_from {
            config_map_ref {
              name = "${var.onify_client_code}-${var.onify_instance}-api"
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

resource "kubernetes_service" "onify-api" {
  metadata {
    name      = "${var.onify_client_code}-${var.onify_instance}-api"
    namespace = kubernetes_namespace.customer_namespace.metadata.0.name
    annotations = {
      "cloud.google.com/load-balancer-type" = "Internal"
    }
  }
  spec {
    selector = {
      app  = "${var.onify_client_code}-${var.onify_instance}-api"
      task = "${var.onify_client_code}-${var.onify_instance}-api"
    }
    port {
      name     = "onify-api"
      port     = 8181
      protocol = "TCP"
    }
    type = "NodePort"
    //type = "LoadBalancer"
  }
  depends_on = [kubernetes_namespace.customer_namespace]
}


resource "kubernetes_ingress" "onify-api" {
  count                  = var.onify-api_external ? 1 : 0
  wait_for_load_balancer = false
  metadata {
    name      = "${var.onify_client_code}-${var.onify_instance}-api"
    namespace = kubernetes_namespace.customer_namespace.metadata.0.name
    annotations = {
      "traefik.ingress.kubernetes.io/router.entrypoints"      = "websecure"
      "traefik.ingress.kubernetes.io/router.tls"              = "true"
      "traefik.ingress.kubernetes.io/router.tls.certresolver" = "default"
    }
  }
  spec {
    rule {
      host = "${var.onify_client_code}-${var.onify_instance}-api.onify.io"
      http {
        path {
          backend {
            service_name = "${var.onify_client_code}-${var.onify_instance}-api"
            service_port = 8181
          }
        }
      }
    }
  }
  depends_on = [kubernetes_namespace.customer_namespace]
}
