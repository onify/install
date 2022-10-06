resource "kubernetes_config_map" "onify-app" {
  metadata {
    name      = "${local.name}-app"
    namespace = "${local.name}"
  }

  data = {
    ONIFY_api_internalUrl = "http://${local.name}-api:8181/api/v2"
  }
  depends_on = [kubernetes_namespace.customer_namespace]
}

resource "kubernetes_stateful_set" "onify-app" {
  metadata {
    name      = "${local.name}-app"
    namespace = kubernetes_namespace.customer_namespace.metadata.0.name
    labels = {
      app  = "${local.name}-app"
      name = "${local.name}-app"
    }
  }
  spec {
    service_name = "${local.name}-app"
    replicas     = var.deployment_replicas
    selector {
      match_labels = {
        app  = "${local.name}-app"
        task = "${local.name}-app"
      }
    }
    template {
      metadata {
        labels = {
          app  = "${local.name}-app"
          task = "${local.name}-app"
        }
      }
      spec {
        image_pull_secrets {
          name = "onify-regcred"
        }
        container {
          image = "eu.gcr.io/onify-images/hub/app:${var.onify-app_version}"
          name  = "onfiy-app"
          resources {
            limits = {
              cpu    = var.onify-app_cpu_limit
              memory = var.onify-app_memory_limit
            }
            requests = {
              cpu    = var.onify-app_cpu_requests
              memory = var.onify-app_memory_requests
            }
          }
          port {
            name           = "onify-app"
            container_port = 3000
          }
          dynamic "env" {
            for_each = var.onify_default_envs
            content {
              name  = env.key
              value = env.value
            }
          }
          dynamic "env" {
            for_each = var.onify_app_envs
            content {
              name  = env.key
              value = env.value
            }
          }
          env_from {
            config_map_ref {
              name = "${local.name}-app"
            }
          }

        }
      }
    }
  }
  depends_on = [kubernetes_namespace.customer_namespace]
}

resource "kubernetes_service" "onify-app" {
  metadata {
    name      = "${local.name}-app"
    namespace = kubernetes_namespace.customer_namespace.metadata.0.name
  }
  spec {
    selector = {
      app  = "${local.name}-app"
      task = "${local.name}-app"
    }
    port {
      name     = "onify-app"
      port     = 3000
      protocol = "TCP"
    }
    type = "NodePort"
  }
  depends_on = [kubernetes_namespace.customer_namespace]
}
