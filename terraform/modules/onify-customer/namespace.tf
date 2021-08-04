resource "kubernetes_namespace" "customer_namespace" {
    metadata {
        name = "${var.onify_client_code}-${var.onify_instance}"
    }
}