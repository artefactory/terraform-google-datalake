locals {
  project_id = "PROJECT_ID" # Replace this with your actual project id
}

provider "google" {
  project = local.project_id
  user_project_override = true
  billing_project       = local.project_id
}

# Used to generate a random string to use as a suffix for the bucket names.
# Only required if you want a special naming convention.
resource "random_string" "suffix" {
  length  = 4
  upper   = false
  special = false
}

module "datalake" {
  source = "artefactory/datalake/google"

  project_id = local.project_id

  # Optional: defines the naming convention to use for the buckets created by the module.
  naming_convention = {
    "prefix" : "${local.project_id}-"
    "suffix" : "-${random_string.suffix.result}"
  }

  # Main config for all your buckets. Each dictionnary corresponds to one bucket.
  buckets_config = [

    # You can create as many buckets as needed following this template.
    {
      "bucket_name" : "YOUR_BUCKET", # Replace this with the name of your bucket.

      # Optional : List of maps that define the Identity and Access Management (IAM) roles and principals for this bucket. 
      # In this example, the "roles/storage.admin" role is granted for all principals for this bucket.
      # More information about GCP roles: https://cloud.google.com/iam/docs/understanding-roles
      "iam_rules" : [
        {
          "role" : "roles/storage.admin",
          "principals" : ["user:YOUR_USER"]
        }
      ],

      "autoclass" : false, # Optional: Default is true. Need to be set to false in order to define lifecycle_rules.

      # Optional: List of maps that define the lifecycle rules for this bucket.
      # More information about lifecycle management: https://cloud.google.com/storage/docs/lifecycle
      "lifecycle_rules" : [
        # In this example, it moves objects to the "ARCHIVE" storage class after 60 days.
        {
          "delay" : 60,
          "storage_class" : "ARCHIVE"
        }
      ],

      # Optional: Notifications will be sent to the Cloud Pub/Sub topic named "TOPIC" when objects are created, updated, or deleted in the bucket.
      "notification_topic" : "TOPIC"
    }
  ]
}
