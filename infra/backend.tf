terraform {
  backend "gcs" {
    bucket = "emmanuel-portfolio-agent-tfstate"
    prefix = "terraform/state"
  }
}