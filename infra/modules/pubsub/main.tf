variable "project_id" {}
variable "environment" {}

# ── Topic: nuevo documento subido ──────────────────────────────
resource "google_pubsub_topic" "new_document" {
  name    = "new-document"
  project = var.project_id
}

# ── Subscription: Cloud Function la consume ─────────────────────
resource "google_pubsub_subscription" "ingest_trigger" {
  name    = "ingest-trigger"
  topic   = google_pubsub_topic.new_document.name
  project = var.project_id

  ack_deadline_seconds = 60

  retry_policy {
    minimum_backoff = "10s"
    maximum_backoff = "300s"
  }
}

# ── Outputs ─────────────────────────────────────────────────────
output "topic_name" {
  value = google_pubsub_topic.new_document.name
}

output "topic_id" {
  value = google_pubsub_topic.new_document.id
}