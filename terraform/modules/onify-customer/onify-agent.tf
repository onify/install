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
    name      = "${local.client_code}-${local.onify_instance}-agent"
    namespace = kubernetes_namespace.customer_namespace.metadata.0.name
    labels = {
      app  = "${local.client_code}-${local.onify_instance}-agent"
      name = "${local.client_code}-${local.onify_instance}"
    }
  }
  spec {
    service_name = "${local.client_code}-${local.onify_instance}-agent"
    replicas     = var.deployment_replicas
    selector {
      match_labels = {
        app  = "${local.client_code}-${local.onify_instance}-agent"
        task = "${local.client_code}-${local.onify_instance}-agent"
      }
    }
    template {
      metadata {
        labels = {
          app  = "${local.client_code}-${local.onify_instance}-agent"
          task = "${local.client_code}-${local.onify_instance}-agent"
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
    name      = "${local.client_code}-${local.onify_instance}-agent"
    namespace = kubernetes_namespace.customer_namespace.metadata.0.name
    annotations = {
      "cloud.google.com/load-balancer-type" = "Internal"
    }
  }
  spec {
    selector = {
      app  = "${local.client_code}-${local.onify_instance}-agent"
      task = "${local.client_code}-${local.onify_instance}-agent"
    }
    port {
      name     = "onify-agent"
      port     = 8080
      protocol = "TCP"
    }
    type = "NodePort"
    //type = "LoadBalancer"
  }
  depends_on = [kubernetes_namespace.customer_namespace]
}

resource "kubernetes_ingress" "onify-agent" {
  count                  = var.onify-agent_external ? 1 : 0
  wait_for_load_balancer = false
  metadata {
    name      = "${local.client_code}-${local.onify_instance}-agent"
    namespace = kubernetes_namespace.customer_namespace.metadata.0.name
    annotations = {
      "traefik.ingress.kubernetes.io/router.entrypoints"      = "websecure"
      "traefik.ingress.kubernetes.io/router.tls"              = "true"
      "traefik.ingress.kubernetes.io/router.tls.certresolver" = var.ssl_staging ? "staging" : "default"
    }
  }
  spec {
    rule {
      host = "agent.${var.external-dns-domain}"
      http {
        path {
          backend {
            service_name = "${local.client_code}-${local.onify_instance}-agent"
            service_port = 8080
          }
        }
      }
    }
  }
  depends_on = [kubernetes_namespace.customer_namespace]
}
