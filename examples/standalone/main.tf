locals {
  project_id = "PROJECT_ID" # Replace this with your actual project id
}

provider "google" {
  user_project_override = true
  billing_project       = local.project_id
}

resource "random_string" "suffix" {
  length  = 4
  upper   = false
  special = false
}

module "datalake" {
  source = "artefactory/datalake/google"

  project_id = local.project_id
  naming_convention = {
    "prefix" : local.project_id
    "suffix" : random_string.suffix.result
  }
  buckets_config = [
    {
      "bucket_name" : "sourcea",
      "iam_rules" : [
        { "role" = "roles/storage.admin", "principals" = ["user:user@user.com"] }
      ]
      "autoclass" : false,
      "lifecycle_rules" : [
      ],
      "notification_topic" : "hello"
    },
    {
      "bucket_name" : "sourceb",
      "iam_rules" : [{ "role" = "roles/storage.admin", "principals" = ["user:user@user.com"] }]
      "autoclass" : false,
      "lifecycle_rules" : [],
    }
  ]
}
