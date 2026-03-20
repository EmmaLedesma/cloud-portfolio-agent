terraform {
  required_version = ">= 1.7"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project               = var.project_id
  region                = var.region
  billing_project       = var.project_id
  user_project_override = true
}

locals {
  gcp_apis = [
    "run.googleapis.com",
    "cloudfunctions.googleapis.com",
    "pubsub.googleapis.com",
    "bigquery.googleapis.com",
    "storage.googleapis.com",
    "secretmanager.googleapis.com",
    "monitoring.googleapis.com",
    "logging.googleapis.com",
    "aiplatform.googleapis.com",
    "discoveryengine.googleapis.com",
    "dialogflow.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "sts.googleapis.com",
    "artifactregistry.googleapis.com",
    "cloudbuild.googleapis.com",
  ]
}

resource "google_project_service" "apis" {
  for_each = toset(local.gcp_apis)

  project            = var.project_id
  service            = each.value
  disable_on_destroy = false
}

module "iam" {
  source = "./modules/iam"

  project_id  = var.project_id
  github_repo = var.github_repo

  depends_on = [google_project_service.apis]
}

module "storage" {
  source = "./modules/storage"

  project_id  = var.project_id
  region      = var.region
  environment = var.environment

  depends_on = [google_project_service.apis]
}

module "pubsub" {
  source = "./modules/pubsub"

  project_id  = var.project_id
  environment = var.environment

  depends_on = [google_project_service.apis]
}

module "bigquery" {
  source = "./modules/bigquery"

  project_id = var.project_id
  region     = var.region

  depends_on = [google_project_service.apis]
}

module "vertex_ai" {
  source = "./modules/vertex_ai"

  project_id = var.project_id
  region     = var.region

  depends_on = [google_project_service.apis]
}

module "cloud_run" {
  source = "./modules/cloud_run"

  project_id            = var.project_id
  region                = var.region
  service_account_email = module.iam.cloud_run_service_account
  data_store_id         = module.vertex_ai.data_store_id
  search_engine_id      = module.vertex_ai.search_engine_id
  bigquery_dataset_id   = module.bigquery.dataset_id
  bigquery_table_id     = module.bigquery.table_id

  depends_on = [google_project_service.apis]
}

module "cloud_functions" {
  source = "./modules/cloud_functions"

  project_id                = var.project_id
  region                    = var.region
  docs_bucket_name          = module.storage.docs_bucket_name
  pubsub_topic_id           = module.pubsub.topic_id
  ingestion_service_account = module.iam.ingestion_service_account

  depends_on = [google_project_service.apis]
}

module "monitoring" {
  source = "./modules/monitoring"

  project_id   = var.project_id
  region       = var.region
  service_name = "portfolio-agent"

  depends_on = [module.cloud_run]
}