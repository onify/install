resource "kubernetes_secret" "onify-app" {
  metadata {
    name      = "${var.onify_client_code}-${var.onify_instance}-onify-app"
    namespace = "${var.onify_client_code}-${var.onify_instance}"
  }
  data = {
    api_token = var.onify-api_app_token
  }
  type = "Opaque"
}

resource "kubernetes_config_map" "onify-app" {
  metadata {
    name      = "${var.onify_client_code}-${var.onify_instance}-onify-app"
    namespace = "${var.onify_client_code}-${var.onify_instance}"
  }

  data = {
    NODE_ENV              = "production"
    ENV_PREFIX            = "ONIFY_"
    INTERPRET_CHAR_AS_DOT = "_"
    ONIFY_api_internalUrl = "http://onify-api-${var.onify_client_code}-${var.onify_instance}:8181/api/v2"
    ONIFY_api_externalUrl = "/api/v2"
  }
}

resource "kubernetes_stateful_set" "onify-app" {
  metadata {
    name      = "${var.onify_client_code}-${var.onify_instance}-onify-app"
    namespace = "${var.onify_client_code}-${var.onify_instance}"
    labels = {
      app  = "${var.onify_client_code}-${var.onify_instance}-onify-app"
      name = "${var.onify_client_code}-${var.onify_instance}-onify-app"
    }
  }
  spec {
    service_name = "${var.onify_client_code}-${var.onify_instance}-onify-app"
    replicas     = var.deployment_replicas
    selector {
      match_labels = {
        app  = "${var.onify_client_code}-${var.onify_instance}-onify-app"
        task = "${var.onify_client_code}-${var.onify_instance}-onify-app"
      }
    }
    template {
      metadata {
        labels = {
          app  = "${var.onify_client_code}-${var.onify_instance}-onify-app"
          task = "${var.onify_client_code}-${var.onify_instance}-onify-app"
        }
      }
      spec {
        image_pull_secrets {
          name = "onify-regcred"
        }
        container {
          image = "eu.gcr.io/onify-images/hub/app:${var.onify-app_version}"
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
            name           = "onify-app"
            container_port = 3000
          }
          env_from {
            config_map_ref {
              name = "${var.onify_client_code}-${var.onify_instance}-onify-app"
            }
          }
          env {
            name  = "ONIFY_disableAdminEndpoints"
            value = false
          }
          env {
            name = "ONIFY_api_admintoken"
            value_from {
              secret_key_ref {
                name = "${var.onify_client_code}-${var.onify_instance}-onify-app"
                key  = "api_token"
              }
            }
          }
        }
      }
    }
  }
  depends_on = [kubernetes_namespace.client]
}

resource "kubernetes_service" "onify-app" {
  metadata {
    name      = "${var.onify_client_code}-${var.onify_instance}-onify-app"
    namespace = "${var.onify_client_code}-${var.onify_instance}"
    annotations = {
      "cloud.google.com/load-balancer-type" = "Internal"
    }
  }
  spec {
    selector = {
      app  = "${var.onify_client_code}-${var.onify_instance}-onify-app"
      task = "${var.onify_client_code}-${var.onify_instance}-onify-app"
    }
    port {
      name     = "onify-app"
      port     = 3000
      protocol = "TCP"
    }
    type = "NodePort"
    //type = "LoadBalancer"
  }
  depends_on = [kubernetes_namespace.client]
}

resource "kubernetes_ingress" "onify-app" {
  wait_for_load_balancer = false
  metadata {
    name      = "${var.onify_client_code}-${var.onify_instance}-onify-app"
    namespace = "${var.onify_client_code}-${var.onify_instance}"

    # labels = {
    #   loadbalancer = "traefik"
    # }
  }
  spec {
    rule {
      host = "${var.onify_client_code}-${var.onify_instance}.onify.io"
      http {
        path {
          backend {
            service_name = "${var.onify_client_code}-${var.onify_instance}-onify-app"
            service_port = 3000
          }
        }
      }
    }
  }
  depends_on = [kubernetes_namespace.client]
}
