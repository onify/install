resource "kubernetes_namespace" "traefik" {
  metadata {
    name = "traefik"
  }
}
resource "kubernetes_service_account" "traefik" {
  metadata {
    name      = "traefik-ingress-controller"
    namespace = "traefik"
  }
  depends_on = [kubernetes_namespace.traefik]
}

resource "kubernetes_cluster_role" "traefik" {
  metadata {
    name = "traefik-ingress-controller"
  }
  rule {
    api_groups = [""]
    resources  = ["services", "endpoints", "secrets"]
    verbs      = ["get", "watch", "list"]
  }
  rule {
    api_groups = ["extensions", "networking.k8s.io"]
    resources  = ["ingresses", "ingressclasses"]
    verbs      = ["get", "watch", "list"]
  }
  rule {
    api_groups = ["extensions"]
    resources  = ["ingresses/status"]
    verbs      = ["update"]
  }
  rule {
    api_groups = ["traefik.containo.us"]
    resources  = ["middlewares", "ingressroutes", "traefikservices", "ingressroutetcps", "ingressrouteudps", "tlsoptions", "tlsstores", "serverstransports"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_cluster_role_binding" "traefik" {
  metadata {
    name = "traefik-ingress-controller"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "traefik-ingress-controller"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "traefik-ingress-controller"
    namespace = "traefik"
    api_group = ""
  }
  depends_on = [kubernetes_cluster_role.traefik, kubernetes_service_account.traefik]
}

resource "kubernetes_deployment" "traefik" {
  metadata {
    name      = "traefik"
    namespace = "traefik"
    labels = {
      k8s-app = "traefik-ingress-lb"
    }
  }
  spec {
    strategy {
      type = "Recreate"
    }
    selector {
      match_labels = {
        k8s-app = "traefik-ingress-lb"
      }
    }
    template {
      metadata {
        labels = {
          k8s-app = "traefik-ingress-lb"
          name    = "traefik-ingress-lb"
        }
      }
      spec {
        host_network                     = true
        service_account_name             = "traefik-ingress-controller"
        termination_grace_period_seconds = 60
        container {
          image = "traefik:${var.traefik-image_version}"
          name  = "traefik-ingress-lb"
          port {
            name           = "web"
            container_port = 80
            host_port      = 80
          }
          port {
            name           = "websecure"
            container_port = 443
            host_port      = 443
          }
          port {
            name           = "admin"
            container_port = 8080
            host_port      = 8080
          }
          security_context {
            capabilities {
              drop = ["ALL"]
              add  = ["NET_BIND_SERVICE"]
            }
          }
          args = [
            "--api.dashboard=true",
            "--api.insecure=true",
            "--entrypoints.web.Address=:80",
            "--entryPoints.websecure.address=:443",
            "--providers.kubernetesingress=true",
            "--entrypoints.web.http.redirections.entryPoint.to=websecure",
            "--log.Level=${var.traefik-log_level}",
            "--certificatesResolvers.default.acme.storage=acme.json",
            "--certificatesResolvers.default.acme.email=hello@onify.io",
            "--certificatesResolvers.default.acme.tlschallenge",
            "--certificatesResolvers.staging.acme.storage=acme.json",
            "--certificatesResolvers.staging.acme.email=hello@onify.io",
            "--certificatesResolvers.staging.acme.caServer=https://acme-staging-v02.api.letsencrypt.org/directory",
            "--certificatesResolvers.staging.acme.tlschallenge",
            "--global.sendAnonymousUsage=true"]
        }
      }
    }
  }
  depends_on = [kubernetes_cluster_role.traefik, kubernetes_service_account.traefik]
}

resource "kubernetes_service" "traefik" {
  metadata {
    name      = "traefik-ingress-service"
    namespace = "traefik"
    annotations = {
      "external-dns.alpha.kubernetes.io/hostname" = "*.${var.external-dns-domain}"
      "external-dns.alpha.kubernetes.io/ttl"      = "120"
    }
  }
  wait_for_load_balancer = false
  spec {
    selector = {
      k8s-app = "traefik-ingress-lb"
    }
    port {
      name     = "web"
      port     = 80
      protocol = "TCP"
    }
    port {
      name     = "websecure"
      port     = 443
      protocol = "TCP"
    }
    port {
      name     = "admin"
      port     = 8080
      protocol = "TCP"
    }
    type = var.gke ? "LoadBalancer" : "NodePort"
  }
  depends_on = [kubernetes_namespace.traefik]
}

resource "kubernetes_ingress" "traefik" {
  wait_for_load_balancer = false
  metadata {
    name      = "traefik"
    namespace = "traefik"
    annotations = {
      "traefik.ingress.kubernetes.io/router.entrypoints"      = "websecure"
      "traefik.ingress.kubernetes.io/router.tls"              = "true"
      "traefik.ingress.kubernetes.io/router.tls.certresolver" = "staging"
      //"traefik.ingress.kubernetes.io/router.middlewares" = "traefik-basic-auth@kubernetescrd"
    }
  }
  spec {
    rule {
      host = "traefik.${var.external-dns-domain}"
      http {
        path {
          backend {
            service_name = kubernetes_service.traefik.metadata.0.name
            service_port = 8080
          }
        }
      }
    }
  }
  depends_on = [kubernetes_namespace.traefik]
}
