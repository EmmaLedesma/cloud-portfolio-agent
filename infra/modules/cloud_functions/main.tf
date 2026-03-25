variable "project_id" {}
variable "region" {}
variable "docs_bucket_name" {}
variable "pubsub_topic_id" {}
variable "ingestion_service_account" {}

# ── Bucket para el código fuente de la Cloud Function ───────────
resource "google_storage_bucket" "function_source" {
  name                        = "${var.project_id}-function-source"
  location                    = var.region
  force_destroy               = true
  uniform_bucket_level_access = true
}

# ── ZIP del código fuente ────────────────────────────────────────
data "archive_file" "ingest_function" {
  type        = "zip"
  source_dir  = "${path.root}/../functions/ingest"
  output_path = "${path.root}/../functions/ingest.zip"
}

resource "google_storage_bucket_object" "ingest_function_source" {
  name   = "ingest-${data.archive_file.ingest_function.output_md5}.zip"
  bucket = google_storage_bucket.function_source.name
  source = data.archive_file.ingest_function.output_path
}

# ── Cloud Function v2 ───────────────────────────────────────────
resource "google_cloudfunctions2_function" "ingest" {
  name     = "ingest-documents"
  location = var.region
  project  = var.project_id

  description = "Re-indexa documentos en Vertex AI Search via Pub/Sub"

  build_config {
    runtime     = "python312"
    entry_point = "ingest_document"

    source {
      storage_source {
        bucket = google_storage_bucket.function_source.name
        object = google_storage_bucket_object.ingest_function_source.name
      }
    }
  }

  service_config {
    max_instance_count    = 3
    min_instance_count    = 0
    available_memory      = "256M"
    timeout_seconds       = 120
    service_account_email = var.ingestion_service_account

    environment_variables = {
      PROJECT_ID    = var.project_id
      DATA_STORE_ID = "portfolio-docs-v2"
    }
  }

  event_trigger {
    trigger_region = var.region
    event_type     = "google.cloud.pubsub.topic.v1.messagePublished"
    pubsub_topic   = var.pubsub_topic_id
    retry_policy   = "RETRY_POLICY_RETRY"
  }
}

# ── Outputs ─────────────────────────────────────────────────────
output "function_name" {
  value = google_cloudfunctions2_function.ingest.name
}

output "function_uri" {
  value = google_cloudfunctions2_function.ingest.service_config[0].uri
}