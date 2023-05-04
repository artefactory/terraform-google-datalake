resource "google_storage_bucket" "buckets" {
  for_each = tomap({ for bucket_config in var.buckets_config : bucket_config.bucket_name => bucket_config })

  name     = "${var.naming_convention.prefix}-${each.value.bucket_name}-${var.naming_convention.suffix}"
  location = var.location

  force_destroy = false
  project       = var.project_id
  storage_class = "STANDARD"
  autoclass {
    enabled = each.value.autoclass
  }

  dynamic "lifecycle_rule" {
    for_each = each.value.lifecycle_rules

    content {
      condition {
        age = lifecycle_rule.value["delay"]
      }
      action {
        type          = "SetStorageClass"
        storage_class = lifecycle_rule.value["storage_class"]
      }
    }
  }

  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
}

locals {
  buckets_config = [{ "bucket_name" : "sourceA", "iam_rules" : [{ "role" = "roles/storage.admin", "principals" = ["blahblah@mail.com"] }] }, { "bucket_name" : "sourceB", "autoclass" : true, "iam_rules" : [{ role = "roles/storage.editor", "principals" = ["blahblah@mail.com"] }], "regex_validation" : "^\\S+$" }]

  iam_list = distinct(flatten([
    for bucket_config in local.buckets_config : [
      for iam_rule in bucket_config.iam_rules : [
        for principal in iam_rule.principals : {
          bucket_name = bucket_config.bucket_name
          role        = iam_rule.role
          principal   = principal
        }
      ]
    ]
  ]))

}

resource "google_storage_bucket_iam_member" "member" {
  for_each = { for entry in local.iam_list : "${entry.bucket_name}.${entry.role}.${entry.principal}" => entry }

  bucket = each.value.bucket_name
  role   = each.value.role
  member = each.value.member
}