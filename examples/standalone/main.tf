locals {
  project_id = "vertex-template-1-1c2a" # Replace this with your actual project id
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
  #source = "artefactory/datalake/google"
  source = "../.."
  project_id = local.project_id

  # Naming convention
  naming_convention = {
    "prefix" : local.project_id
    "suffix" : random_string.prefix.result
  }

  # List of buckets to create
  buckets = [
    "source-a",
    "source-b",
    "source-c",
    "source-d"
  ]

  # List of storage admins 
  storage_admins = ["user:rida.kejji@artefact.com"]

  # List of object admins
  object_admins = ["user:rida.kejji@artefact.com"]

  # List of viewers
  object_viewers = ["user:rida.kejji@artefact.com"]

  # Notification topic 
  notification_topic_id = "datalake-bucket-notifications-f"

}
