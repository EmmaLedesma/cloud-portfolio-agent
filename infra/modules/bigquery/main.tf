variable "project_id" {}
variable "region" {}

# ── Dataset ─────────────────────────────────────────────────────
resource "google_bigquery_dataset" "analytics" {
  dataset_id  = "portfolio_agent"
  description = "Analytics de conversaciones del agente"
  location    = var.region
  project     = var.project_id

  delete_contents_on_destroy = true
}

# ── Tabla: conversaciones ────────────────────────────────────────
resource "google_bigquery_table" "conversations" {
  dataset_id          = google_bigquery_dataset.analytics.dataset_id
  table_id            = "conversations"
  project             = var.project_id
  deletion_protection = false

  schema = jsonencode([
    { name = "conversation_id", type = "STRING",    mode = "REQUIRED" },
    { name = "timestamp",       type = "TIMESTAMP", mode = "REQUIRED" },
    { name = "user_message",    type = "STRING",    mode = "REQUIRED" },
    { name = "agent_response",  type = "STRING",    mode = "REQUIRED" },
    { name = "latency_ms",      type = "INTEGER",   mode = "NULLABLE" },
    { name = "sources_used",    type = "STRING",    mode = "NULLABLE" },
    { name = "session_id",      type = "STRING",    mode = "NULLABLE" }
  ])
}

# ── Outputs ─────────────────────────────────────────────────────
output "dataset_id" {
  value = google_bigquery_dataset.analytics.dataset_id
}

output "table_id" {
  value = google_bigquery_table.conversations.table_id
}