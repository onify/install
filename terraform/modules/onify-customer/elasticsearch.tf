### EXAMPLE SSD STORAGE CLASS
resource "kubernetes_storage_class" "ssd" {
  metadata {
    name = "ssd"
  }
  storage_provisioner = "kubernetes.io/gce-pd"
  parameters = {
    type = "pd-ssd"
  }
  mount_options = ["file_mode=0700", "dir_mode=0777", "mfsymlinks", "uid=1000", "gid=1000", "nobrl", "cache=none"]
}

resource "kubernetes_service" "elasticsearch" {
  metadata {
    name      = "${var.client}-elasticsearch"
    namespace = var.client
    labels = {
      app = var.client
    }
  }
  spec {
    selector = {
      app = "${var.client}-elasticsearch"
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
    //type = "LoadBalancer"
  }
  depends_on = [kubernetes_namespace.client]
}


resource "kubernetes_stateful_set" "elasticsearch" {
  metadata {
    name      = "${var.client}-elasticsearch"
    namespace = var.client
    labels = {
      app = "${var.client}-elasticsearch"
    }
  }
  spec {
    pod_management_policy  = "Parallel"
    replicas               = 1
    revision_history_limit = 5
    selector {
      match_labels = {
        app = "${var.client}-elasticsearch"
      }
    }
    service_name = "${var.client}-elasticsearch"
    template {
      metadata {
        labels = {
          app = "${var.client}-elasticsearch"
        }
      }
      spec {
        security_context {
          fs_group        = 2000
          run_as_user     = 1000
          run_as_non_root = true
        }
        container {
          name  = "${var.client}-elasticsearch"
          image = "docker.elastic.co/elasticsearch/elasticsearch-oss:7.6.2"

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
            value = "${var.client}-onify-elasticsearch"
          }
          volume_mount {
            name       = "data"
            mount_path = "/usr/share/elasticsearch/data"
          }

          # liveness_probe {
          #   http_get {
          #     path   = "/_cluster/health"
          #     port   = 9200
          #     scheme = "HTTP"
          #   }
          #   initial_delay_seconds = 30
          #   timeout_seconds       = 30
          # }
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
    volume_claim_template {
      metadata {
        name      = "data"
        namespace = var.client
      }
      spec {
        access_modes = ["ReadWriteOnce"]
        #storage_class_name = "standard" //could be "ssd" for faster disks
        resources {
          requests = {
            storage = "10Gi"
          }
        }
      }
    }
  }
}
