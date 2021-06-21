resource "kubernetes_secret" "docker-onify" {
  metadata {
    name      = "onify-regcred"
    namespace = "${var.onify_client_code}-${var.onify_instance}"
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

resource "kubernetes_stateful_set" "onify-agent" {
  metadata {
    name      = "${var.onify_client_code}-${var.onify_instance}-onify-agent"
    namespace = "${var.onify_client_code}-${var.onify_instance}"
    labels = {
      app  = "${var.onify_client_code}-${var.onify_instance}-onify-agent"
      name = "${var.onify_client_code}-${var.onify_instance}"
    }
  }
  spec {
    service_name = "${var.onify_client_code}-${var.onify_instance}-onify-agent"
    replicas     = var.deployment_replicas
    selector {
      match_labels = {
        app  = "${var.onify_client_code}-${var.onify_instance}-onify-agent"
        task = "${var.onify_client_code}-${var.onify_instance}-onify-agent"
      }
    }
    template {
      metadata {
        labels = {
          app  = "${var.onify_client_code}-${var.onify_instance}-onify-agent"
          task = "${var.onify_client_code}-${var.onify_instance}-onify-agent"
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
    name      = "${var.onify_client_code}-${var.onify_instance}-onify-agent"
    namespace = "${var.onify_client_code}-${var.onify_instance}"
    annotations = {
      "cloud.google.com/load-balancer-type" = "Internal"
    }
  }
  spec {
    selector = {
      app  = "${var.onify_client_code}-${var.onify_instance}-onify-agent"
      task = "${var.onify_client_code}-${var.onify_instance}-onify-agent"
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

resource "kubernetes_ingress" "onify-agent" {
  count                  = var.onify-agent_external ? 1 : 0
  wait_for_load_balancer = false
  metadata {
    name      = "${var.onify_client_code}-${var.onify_instance}-onify-agent"
    namespace = "${var.onify_client_code}-${var.onify_instance}"

    # labels = {
    #   loadbalancer = "traefik"
    # }
  }
  spec {
    rule {
      host = "${var.onify_client_code}-${var.onify_instance}-agent-server.onify.io"
      http {
        path {
          backend {
            service_name = "${var.onify_client_code}-${var.onify_instance}-onify-agent"
            service_port = 8181
          }
        }
      }
    }
  }
  depends_on = [kubernetes_namespace.client]
}
