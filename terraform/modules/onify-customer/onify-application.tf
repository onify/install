resource "kubernetes_secret" "onify-app" {
  metadata {
    name      = "${var.onify_client_code}-${var.onify_instance}-app"
    namespace = "${var.onify_client_code}-${var.onify_instance}"
  }
  data = {
    api_token = var.onify-api_app_token
  }
  type = "Opaque"
}

resource "kubernetes_config_map" "onify-app" {
  metadata {
    name      = "${var.onify_client_code}-${var.onify_instance}-app"
    namespace = "${var.onify_client_code}-${var.onify_instance}"
  }

  data = {
    NODE_ENV              = "production"
    ENV_PREFIX            = "ONIFY_"
    INTERPRET_CHAR_AS_DOT = "_"
    ONIFY_api_internalUrl = "http://${var.onify_client_code}-${var.onify_instance}-api:8181/api/v2"
    ONIFY_api_externalUrl = "/api/v2"
  }
}

resource "kubernetes_stateful_set" "onify-app" {
  metadata {
    name      = "${var.onify_client_code}-${var.onify_instance}-app"
    namespace = "${var.onify_client_code}-${var.onify_instance}"
    labels = {
      app  = "${var.onify_client_code}-${var.onify_instance}-app"
      name = "${var.onify_client_code}-${var.onify_instance}-app"
    }
  }
  spec {
    service_name = "${var.onify_client_code}-${var.onify_instance}-app"
    replicas     = var.deployment_replicas
    selector {
      match_labels = {
        app  = "${var.onify_client_code}-${var.onify_instance}-app"
        task = "${var.onify_client_code}-${var.onify_instance}-app"
      }
    }
    template {
      metadata {
        labels = {
          app  = "${var.onify_client_code}-${var.onify_instance}-app"
          task = "${var.onify_client_code}-${var.onify_instance}-app"
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
              name = "${var.onify_client_code}-${var.onify_instance}-app"
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
                name = "${var.onify_client_code}-${var.onify_instance}-app"
                key  = "api_token"
              }
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "onify-app" {
  metadata {
    name      = "${var.onify_client_code}-${var.onify_instance}-app"
    namespace = "${var.onify_client_code}-${var.onify_instance}"
    annotations = {
      "cloud.google.com/load-balancer-type" = "Internal"
    }
  }
  spec {
    selector = {
      app  = "${var.onify_client_code}-${var.onify_instance}-app"
      task = "${var.onify_client_code}-${var.onify_instance}-app"
    }
    port {
      name     = "onify-app"
      port     = 3000
      protocol = "TCP"
    }
    type = "NodePort"
  }
}

resource "kubernetes_ingress" "onify-app" {
  wait_for_load_balancer = false
  metadata {
    name      = "${var.onify_client_code}-${var.onify_instance}-app"
    namespace = "${var.onify_client_code}-${var.onify_instance}"
    annotations = {
      "traefik.ingress.kubernetes.io/router.entrypoints"      = "websecure"
      "traefik.ingress.kubernetes.io/router.tls"              = "true"
      "traefik.ingress.kubernetes.io/router.tls.certresolver" = "default"
    }
  }
  spec {
    rule {
      host = "${var.onify_client_code}-${var.onify_instance}-app.onify.io"
      http {
        path {
          backend {
            service_name = "${var.onify_client_code}-${var.onify_instance}-app"
            service_port = 3000
          }
        }
      }
    }
  }
}
