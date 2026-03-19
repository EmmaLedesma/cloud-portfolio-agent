output "workload_identity_provider" {
  description = "Usar este valor en el workflow de GitHub Actions"
  value       = module.iam.workload_identity_provider
}

output "cicd_service_account" {
  value = module.iam.cicd_service_account
}

output "frontend_bucket_url" {
  description = "URL pública del frontend"
  value       = module.storage.frontend_bucket_url
}

output "docs_bucket_name" {
  description = "Bucket para documentos del RAG"
  value       = module.storage.docs_bucket_name
}

output "pubsub_topic_name" {
  description = "Topic de Pub/Sub para nuevos documentos"
  value       = module.pubsub.topic_name
}

output "bigquery_dataset_id" {
  description = "Dataset de BigQuery para analytics"
  value       = module.bigquery.dataset_id
}

output "vertex_ai_data_store_id" {
  description = "ID del data store de Vertex AI Search"
  value       = module.vertex_ai.data_store_id
}

output "vertex_ai_search_engine_id" {
  description = "ID del search engine de Vertex AI Search"
  value       = module.vertex_ai.search_engine_id
}