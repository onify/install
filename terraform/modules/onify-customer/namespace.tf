resource "kubernetes_namespace" "customer_namespace" {
    name = "${var.onify_client_code}-${var.onify_instance}"
  }
}