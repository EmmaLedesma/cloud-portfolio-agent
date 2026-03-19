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