locals {
  project_id = "la-sandbox-de-reda-fee9" # Replace this with your actual project id
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
    "source-b"
  ]

  # List of storage admins 
  storage_admins = ["user:user@user.com"]

  # List of object admins
  object_admins = ["user:user@user.com"]

  # List of viewers
  object_viewers = ["user:user@user.com"]

  # Notification topic 
  notification_topic_id = "datalake-bucket-notifications-a"

  # Custom regex
  object_validation_regex=  "^\\S+$" #"\\s"

}
