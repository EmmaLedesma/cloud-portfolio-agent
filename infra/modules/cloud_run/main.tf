variable "project_id" {}
variable "region" {}
variable "service_account_email" {}
variable "data_store_id" {}
variable "search_engine_id" {}
variable "bigquery_dataset_id" {}
variable "bigquery_table_id" {}

resource "google_cloud_run_v2_service" "agent" {
  name     = "portfolio-agent"
  location = var.region
  project  = var.project_id

  ingress = "INGRESS_TRAFFIC_ALL"

  template {
    service_account = var.service_account_email

    containers {
      image = "us-docker.pkg.dev/cloudrun/container/hello"

      env {
        name  = "PROJECT_ID"
        value = var.project_id
      }
      env {
        name  = "DATA_STORE_ID"
        value = var.data_store_id
      }
      env {
        name  = "SEARCH_ENGINE_ID"
        value = var.search_engine_id
      }
      env {
        name  = "BIGQUERY_DATASET"
        value = var.bigquery_dataset_id
      }
      env {
        name  = "BIGQUERY_TABLE"
        value = var.bigquery_table_id
      }
      env {
        name  = "REGION"
        value = var.region
      }

      resources {
        limits = {
          cpu    = "1"
          memory = "512Mi"
        }
      }
    }
  }
}

# Acceso público al servicio
resource "google_cloud_run_v2_service_iam_member" "public" {
  project  = var.project_id
  location = var.region
  name     = google_cloud_run_v2_service.agent.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

output "service_url" {
  value = google_cloud_run_v2_service.agent.uri
}

output "service_name" {
  value = google_cloud_run_v2_service.agent.name
}