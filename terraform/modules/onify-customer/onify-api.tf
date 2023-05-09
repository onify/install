resource "kubernetes_config_map" "onify-api" {
  metadata {
    name      = "${local.client_code}-${local.onify_instance}-api"
    namespace = kubernetes_namespace.customer_namespace.metadata.0.name
  }

  data = {
    ONIFY_db_elasticsearch_host = var.elasticsearch_address != null ? var.elasticsearch_address : "http://${local.client_code}-${local.onify_instance}-elasticsearch:9200"
    ONIFY_websockets_agent_url  = "ws://${local.client_code}-${local.onify_instance}-agent:8080/hub"
  }
  depends_on = [kubernetes_namespace.customer_namespace]
}

resource "kubernetes_stateful_set" "onify-api" {
  metadata {
    name      = "${local.client_code}-${local.onify_instance}-api"
    namespace = kubernetes_namespace.customer_namespace.metadata.0.name
    labels = {
      app  = "${local.client_code}-${local.onify_instance}-api"
      name = "${local.client_code}-${local.onify_instance}-api"
    }
  }
  spec {
    service_name = "${local.client_code}-${local.onify_instance}-api"
    replicas     = var.deployment_replicas
    selector {
      match_labels = {
        app  = "${local.client_code}-${local.onify_instance}-api"
        task = "${local.client_code}-${local.onify_instance}-api"
      }
    }
    template {
      metadata {
        labels = {
          app  = "${local.client_code}-${local.onify_instance}-api"
          task = "${local.client_code}-${local.onify_instance}-api"
        }
      }
      spec {
        image_pull_secrets {
          name = "onify-regcred"
        }
        container {
          image = "eu.gcr.io/onify-images/hub/api:${var.onify-api_version}"
          name  = "onify-api"
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
           dynamic "env" {
            for_each = var.onify_api_envs
            content {
              name  = env.key
              value = env.value
            }
          }
          env_from {
            config_map_ref {
              name = "${local.client_code}-${local.onify_instance}-api"
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
    name      = "${local.client_code}-${local.onify_instance}-api"
    namespace = kubernetes_namespace.customer_namespace.metadata.0.name
    annotations = {
      "cloud.google.com/load-balancer-type" = "Internal"
    }
  }
  spec {
    selector = {
      app  = "${local.client_code}-${local.onify_instance}-api"
      task = "${local.client_code}-${local.onify_instance}-api"
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
    name      = "${local.client_code}-${local.onify_instance}-api"
    namespace = kubernetes_namespace.customer_namespace.metadata.0.name
    annotations = {
      "traefik.ingress.kubernetes.io/router.entrypoints"      = "websecure"
      "traefik.ingress.kubernetes.io/router.tls"              = "true"
      "traefik.ingress.kubernetes.io/router.tls.certresolver" = var.ssl_staging ? "staging" : "default"
    }
  }
  spec {
    rule {
      host = "api.${var.external-dns-domain}"
      http {
        path {
          backend {
            service_name = "${local.client_code}-${local.onify_instance}-api"
            service_port = 8181
          }
        }
      }
    }
  }
  depends_on = [kubernetes_namespace.customer_namespace]
}
