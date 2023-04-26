locals {
  project_id = "PROJECT_ID" # Replace this with your actual project id
}

resource "random_string" "prefix" {
  length  = 4
  upper   = false
  special = false
}

provider "google" {
  user_project_override = true
  billing_project       = local.project_id
}

module "datalake" {
  source = "artefactory/datalake/google"

  project_id = local.project_id

  # Naming convention
  naming_convention = {
    "prefix": local.project_id
    "suffix": random_string.prefix.result
  }

  # List of buckets to create
  buckets = [
    "source-a",
    "source-b"
  ]
}
