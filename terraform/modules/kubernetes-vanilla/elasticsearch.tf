resource "kubernetes_service" "elasticsearch" {
  metadata {
    name      = "${local.name}-elasticsearch"
    namespace = kubernetes_namespace.customer_namespace.metadata.0.name
    labels = {
      app = "${local.name}"
    }
  }
  spec {
    selector = {
      app = "${local.name}-elasticsearch"
    }
    port {
      name     = "client"
      port     = 9200
      protocol = "TCP"
    }
    port {
      name     = "nodes"
      port     = 9300
      protocol = "TCP"
    }
    type = "NodePort"
  }
  depends_on = [kubernetes_namespace.customer_namespace]
}


resource "kubernetes_stateful_set" "elasticsearch" {
  metadata {
    name      = "${local.name}-elasticsearch"
    namespace = "${local.name}"
    labels = {
      app = "${local.name}-elasticsearch"
    }
  }
  spec {
    pod_management_policy  = "Parallel"
    replicas               = 1
    revision_history_limit = 5
    selector {
      match_labels = {
        app = "${local.name}-elasticsearch"
      }
    }
    service_name = "${local.name}-elasticsearch"
    template {
      metadata {
        labels = {
          app = "${local.name}-elasticsearch"
        }
      }
      spec {
        security_context {
          fs_group        = 2000
          run_as_user     = 1000
          run_as_non_root = true
        }
        container {
          name  = "${local.name}-elasticsearch"
          image = "docker.elastic.co/elasticsearch/elasticsearch:${var.elasticsearch_version}"

          port {
            name           = "nodes"
            container_port = 9300
          }
          port {
            name           = "client"
            container_port = 9200
          }
          env {
            name  = "discovery.type"
            value = "single-node"
          }
          env {
            name  = "cluster.name"
            value = "${local.name}-onify-elasticsearch"
          }
          dynamic "env" {
            for_each = var.elasticsearch_heapsize != null ? [1] : []
            content {
              name  = "ES_JAVA_OPTS"
              value = "-Xms${var.elasticsearch_heapsize} -Xmx${var.elasticsearch_heapsize}"
            }
          }
          
          resources {
            limits = {
              memory = var.elasticsearch_memory_limit
            }
          }
        }
        termination_grace_period_seconds = 300
      }
    }
    update_strategy {
      type = "RollingUpdate"

      rolling_update {
        partition = 1
      }
    }
  }
  depends_on = [kubernetes_namespace.customer_namespace]
}
