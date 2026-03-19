variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region para todos los recursos"
  type        = string
  default     = "us-central1"
}

variable "github_repo" {
  description = "Repo de GitHub en formato owner/repo"
  type        = string
  default     = "EmmaLedesma/cloud-portfolio-agent"
}

variable "environment" {
  description = "Nombre del entorno"
  type        = string
  default     = "prod"
}