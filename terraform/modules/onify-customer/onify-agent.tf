resource "kubernetes_secret" "docker-onify" {
  metadata {
    name      = "onify-regcred"
    namespace = var.client
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
}

resource "kubernetes_deployment" "onify-agent" {
  metadata {
    name      = "onify-agent-${var.client}"
    namespace = var.client
    labels = {
      app  = "onify-agent-${var.client}"
      name = var.client
    }
  }
  spec {
    replicas = var.deployment_replicas
    selector {
      match_labels = {
        app  = "onify-agent-${var.client}"
        task = "onify-agent-${var.client}"
      }
    }
    template {
      metadata {
        labels = {
          app  = "onify-agent-${var.client}"
          task = "onify-agent-${var.client}"
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
              cpu    = var.cpu_limit
              memory = var.memory_limit
            }
            requests = {
              cpu    = var.cpu_requests
              memory = var.memory_requests
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
          env {
            name  = "log_level"
            value = "2"
          }
          env {
            name  = "log_type"
            value = "1"
          }
          env {
            name  = "hub_version"
            value = "v2"
          }
        }
      }
    }
  }
  depends_on = [kubernetes_namespace.client]
}

resource "kubernetes_service" "onify-agent" {
  metadata {
    name      = "onify-agent-${var.client}"
    namespace = var.client
    annotations = {
      "cloud.google.com/load-balancer-type" = "Internal"
    }
  }
  spec {
    selector = {
      app  = "onify-agent-${var.client}"
      task = "onify-agent-${var.client}"
    }
    port {
      name     = "onify-agent"
      port     = 8080
      protocol = "TCP"
    }
    type = "NodePort"
    //type = "LoadBalancer"
  }
  depends_on = [kubernetes_namespace.client]
}
