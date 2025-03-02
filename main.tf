# main.tf
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.32.0"
    }
  }
}

module "bucket_module" {
source = "./module/gcs_bucket"
project = var.project
env = var.env
}

module "service_account_module" {
source = "./module/service_account"
project = var.project
env = var.env
}
