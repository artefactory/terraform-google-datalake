locals {
  project_id = "<PROJECT_ID>" # Replace this with your actual project id
}

provider "google" {
  project               = local.project_id
  user_project_override = true
  billing_project       = local.project_id
}

module "datalake" {
  source = "artefactory/datalake/google"
  project_id = local.project_id
  buckets_config = yamldecode(file("./config.yaml"))["buckets_config"]
}