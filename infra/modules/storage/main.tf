variable "project_id" {}
variable "region" {}
variable "environment" {}

# ── Bucket: frontend estático ───────────────────────────────────
resource "google_storage_bucket" "frontend" {
  name                        = "${var.project_id}-frontend"
  location                    = var.region
  force_destroy               = true
  uniform_bucket_level_access = true

  website {
    main_page_suffix = "index.html"
    not_found_page   = "index.html"
  }

  cors {
    origin          = ["*"]
    method          = ["GET"]
    response_header = ["Content-Type"]
    max_age_seconds = 3600
  }
}

# Acceso público al frontend
resource "google_storage_bucket_iam_member" "frontend_public" {
  bucket = google_storage_bucket.frontend.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}

# ── Bucket: documentos del RAG ──────────────────────────────────
resource "google_storage_bucket" "docs" {
  name                        = "${var.project_id}-docs"
  location                    = var.region
  force_destroy               = true
  uniform_bucket_level_access = true
}

# La SA de ingesta puede leer y escribir documentos
resource "google_storage_bucket_iam_member" "docs_ingestion" {
  bucket = google_storage_bucket.docs.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:sa-ingestion@${var.project_id}.iam.gserviceaccount.com"
}

# ── Outputs ─────────────────────────────────────────────────────
output "frontend_bucket_name" {
  value = google_storage_bucket.frontend.name
}

output "frontend_bucket_url" {
  value = "https://storage.googleapis.com/${google_storage_bucket.frontend.name}/index.html"
}

output "docs_bucket_name" {
  value = google_storage_bucket.docs.name
}