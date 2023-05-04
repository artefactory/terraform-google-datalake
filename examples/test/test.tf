locals {
  project_id     = "la-sandbox-de-reda-fee9" # Replace this with your actual project id
  buckets_config = [{ "bucket_name" : "sourceA", "autoclass" : true, "lifecycle_rules" : [] }]
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
  source     = "../../"
  project_id = local.project_id
  buckets_config = [
    {
      "bucket_name" : "sourceA",
      "iam_rules" : [{ "role" = "roles/storage.admin", "principals" = ["user:blahblah@mail.com"] },{ "role" = "roles/storage.editor", "principals" = ["user:blaehblah@mail.com"] }],
      "autoclass" : false,
      "lifecycle_rules" : [
      ],
      "notification_topic":"hello"
    },
    {
      "bucket_name" : "sourceB",
      "iam_rules" : [{ "role" = "roles/storage.admin", "principals" = ["user:blahblah@mail.com"] },{ "role" = "roles/storage.editor", "principals" = ["user:blaehblah@mail.com"] }],
      "autoclass" : false,
      "lifecycle_rules" : [
      ],
      "notification_topic":"hello2"
    }
  ]
}
