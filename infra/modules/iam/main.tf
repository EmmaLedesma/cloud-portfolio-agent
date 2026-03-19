variable "project_id" {}
variable "github_repo" {}

# ── Workload Identity Pool ──────────────────────────────────────
resource "google_iam_workload_identity_pool" "github" {
  workload_identity_pool_id = "github-actions-pool"
  display_name              = "GitHub Actions Pool"
  description               = "Pool para CI/CD desde GitHub Actions"
}

# ── Workload Identity Provider ──────────────────────────────────
resource "google_iam_workload_identity_pool_provider" "github" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.github.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-provider"
  display_name                       = "GitHub OIDC Provider"

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }

  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.actor"      = "assertion.actor"
    "attribute.repository" = "assertion.repository"
  }

  attribute_condition = "assertion.repository == '${var.github_repo}'"
}

# ── Service Accounts ────────────────────────────────────────────
resource "google_service_account" "cicd" {
  account_id   = "sa-cicd"
  display_name = "CI/CD — GitHub Actions"
  description  = "Usada por GitHub Actions para deployar infra y servicios"
}

resource "google_service_account" "cloud_run" {
  account_id   = "sa-cloud-run"
  display_name = "Cloud Run — Portfolio Agent"
  description  = "Runtime del agente conversacional"
}

resource "google_service_account" "ingestion" {
  account_id   = "sa-ingestion"
  display_name = "Cloud Function — Ingesta RAG"
  description  = "Indexa documentos en Vertex AI Search"
}

# ── Binding: GitHub Actions → SA CI/CD ─────────────────────────
resource "google_service_account_iam_member" "cicd_wif_binding" {
  service_account_id = google_service_account.cicd.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github.name}/attribute.repository/${var.github_repo}"
}

# ── Roles SA CI/CD ──────────────────────────────────────────────
locals {
  cicd_roles = [
    "roles/run.admin",
    "roles/cloudfunctions.admin",
    "roles/storage.admin",
    "roles/iam.serviceAccountUser",
    "roles/artifactregistry.writer",
    "roles/bigquery.dataEditor",
    "roles/pubsub.admin",
    "roles/secretmanager.secretAccessor",
  ]
}

resource "google_project_iam_member" "cicd_roles" {
  for_each = toset(local.cicd_roles)

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.cicd.email}"
}

# ── Roles SA Cloud Run ──────────────────────────────────────────
locals {
  cloud_run_roles = [
    "roles/aiplatform.user",
    "roles/discoveryengine.viewer",
    "roles/bigquery.dataEditor",
    "roles/secretmanager.secretAccessor",
    "roles/pubsub.publisher",
  ]
}

resource "google_project_iam_member" "cloud_run_roles" {
  for_each = toset(local.cloud_run_roles)

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.cloud_run.email}"
}

# ── Outputs ─────────────────────────────────────────────────────
output "workload_identity_provider" {
  value = google_iam_workload_identity_pool_provider.github.name
}

output "cicd_service_account" {
  value = google_service_account.cicd.email
}

output "cloud_run_service_account" {
  value = google_service_account.cloud_run.email
}

output "ingestion_service_account" {
  value = google_service_account.ingestion.email
}