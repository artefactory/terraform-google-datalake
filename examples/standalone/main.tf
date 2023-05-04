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
  source     = "artefactory/datalake/google"
  project_id = local.project_id
  buckets_config = [
    {
      "name" : "sourceA",
      "iam_rules" : [
        {
          role = "roles/storage.admin"
          principals = [
            "blahblah@mail.com"
          ]
        }
      ],
      "lifecycle_rules" : [
        {
          "delay" : 60,
          "storage_class" : "ARCHIVE",
        }
      ]
    },
    {
      "name" : "sourceB",
      "autoclass" : true,
      "iam_rules" : [
        {
          role = "roles/storage.editor"
          principals = [
            "blahblah@mail.com"
          ]
        }
      ],
      "regex_validation" : "^\\S+$"
    }
  ]
}
