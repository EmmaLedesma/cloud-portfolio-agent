variable "project_id" {}
variable "region" {}

# ── Data Store ──────────────────────────────────────────────────
resource "google_discovery_engine_data_store" "portfolio" {
  project                     = var.project_id
  location                    = "global"
  data_store_id               = "portfolio-docs"
  display_name                = "Portfolio Documents"
  industry_vertical           = "GENERIC"
  content_config              = "CONTENT_REQUIRED"
  solution_types              = ["SOLUTION_TYPE_SEARCH"]
  create_advanced_site_search = false
}

# ── Search Engine ───────────────────────────────────────────────
resource "google_discovery_engine_search_engine" "portfolio" {
  project       = var.project_id
  location      = "global"
  engine_id     = "portfolio-search"
  display_name  = "Portfolio Search Engine"
  collection_id = "default_collection"
  data_store_ids = [
    google_discovery_engine_data_store.portfolio.data_store_id
  ]
  industry_vertical = "GENERIC"

  search_engine_config {
    search_tier    = "SEARCH_TIER_STANDARD"
    search_add_ons = ["SEARCH_ADD_ON_LLM"]
  }
}

# ── Outputs ─────────────────────────────────────────────────────
output "data_store_id" {
  value = google_discovery_engine_data_store.portfolio.data_store_id
}

output "search_engine_id" {
  value = google_discovery_engine_search_engine.portfolio.engine_id
}