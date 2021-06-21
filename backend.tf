# # CAN ONLY BE USED IF MODULE GCS EXISTS
terraform {
  backend "gcs" {
    bucket = "onify-demo-terraform"
    prefix = "terraform/state/onify-demo"
  }
}