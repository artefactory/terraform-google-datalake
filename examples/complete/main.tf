
locals {
  project_id = "<PROJECT_ID>" # Replace this with your actual project id
}

provider "google" {
  project               = local.project_id
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
  
  buckets_config = yamldecode(file("./config.yaml"))["buckets_config"]

}
