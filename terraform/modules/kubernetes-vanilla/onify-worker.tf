resource "kubernetes_stateful_set" "onify-worker" {
  metadata {
    name      = "${local.name}-worker"
    namespace = kubernetes_namespace.customer_namespace.metadata.0.name
    labels = {
      app  = "${local.name}-worker"
      name = "${local.name}-worker"
    }
  }
  spec {
    service_name = "${local.name}-worker"
    replicas     = var.deployment_replicas
    selector {
      match_labels = {
        app  = "${local.name}-worker"
        task = "${local.name}-worker"
      }
    }
    template {
      metadata {
        labels = {
          app  = "${local.name}-worker"
          task = "${local.name}-worker"
        }
      }
      spec {
        image_pull_secrets {
          name = "onify-regcred"
        }
        container {
          image = "eu.gcr.io/onify-images/hub/api:${var.onify-worker_version}"
          name  = "onify-worker"
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
          dynamic "env" {
            for_each = var.onify_default_envs
            content {
              name  = env.key
              value = env.value
            }
          }
          dynamic "env" {
            for_each = var.onify_worker_envs
            content {
              name  = env.key
              value = env.value
            }
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
              name = "${local.name}-api"
            }
          }
        }
      }
    }
  }
  depends_on = [kubernetes_namespace.customer_namespace]
}
