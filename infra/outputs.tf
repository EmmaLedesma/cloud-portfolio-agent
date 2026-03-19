output "workload_identity_provider" {
  description = "Usar este valor en el workflow de GitHub Actions"
  value       = module.iam.workload_identity_provider
}

output "cicd_service_account" {
  value = module.iam.cicd_service_account
}