locals {
  project_id = "atf-sbx-barthelemy" # Replace this with your actual project id
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
  source = "../../"
  project_id = local.project_id
  buckets_config = [
    {
      "bucket_name" : "sourceA",
      "autoclass": true,
      "lifecycle_rules" : [
      ]
    }
  ]
}