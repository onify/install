resource "kubernetes_secret" "docker-onify" {
  metadata {
    name      = "onify-regcred"
    namespace = kubernetes_namespace.customer_namespace.metadata.0.name
  }

  data = {
    ".dockerconfigjson" = <<DOCKER
{
  "auths": {
    "eu.gcr.io": {
      "auth": "${base64encode("_json_key:${file("${var.gcr_registry_keyfile}")}")}"
    }
  }
}
DOCKER
  }
  type = "kubernetes.io/dockerconfigjson"
  depends_on = [kubernetes_namespace.customer_namespace]
}

resource "kubernetes_stateful_set" "onify-agent" {
  metadata {
    name      = "${local.name}-agent"
    namespace = kubernetes_namespace.customer_namespace.metadata.0.name
    labels = {
      app  = "${local.name}-agent"
      name = "${local.name}"
    }
  }
  spec {
    service_name = "${local.name}-agent"
    replicas     = var.deployment_replicas
    selector {
      match_labels = {
        app  = "${local.name}-agent"
        task = "${local.name}-agent"
      }
    }
    template {
      metadata {
        labels = {
          app  = "${local.name}-agent"
          task = "${local.name}-agent"
        }
      }
      spec {
        image_pull_secrets {
          name = "onify-regcred"
        }
        container {
          image = "eu.gcr.io/onify-images/hub/agent-server:${var.onify-agent_version}"
          name  = "onfiy-agent"
          resources {
            limits = {
              cpu    = var.onify-agent_cpu_limit
              memory = var.onify-agent_memory_limit
            }
            requests = {
              cpu    = var.onify-agent_cpu_requests
              memory = var.onify-agent_memory_requests
            }
          }
          #   liveness_probe {
          #     http_get {
          #       path = "/health"
          #       port = 9999
          #     }
          #     initial_delay_seconds = 3
          #     period_seconds        = 3
          #   }
          port {
            name           = "onify-agent"
            container_port = 8080
          }
          dynamic "env" {
            for_each = var.onify_agent_envs
            content {
              name  = env.key
              value = env.value
            }
          }
        }
      }
    }
  }
  depends_on = [kubernetes_namespace.customer_namespace]
}

resource "kubernetes_service" "onify-agent" {
  metadata {
    name      = "${local.name}-agent"
    namespace = kubernetes_namespace.customer_namespace.metadata.0.name
  }
  spec {
    //external_traffic_policy = "Local"
    selector = {
      app  = "${local.name}-agent"
      task = "${local.name}-agent"
    }
    port {
      name     = "onify-agent"
      port     = 8080
      protocol = "TCP"
    }
    //type = "NodePort"
    type = "ClusterIP"
  }
  depends_on = [kubernetes_namespace.customer_namespace]
}
