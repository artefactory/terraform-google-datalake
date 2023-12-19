
locals {
  iam_list = distinct(flatten([
    for bucket_config in var.buckets_config : [
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
  for_each   = { for entry in local.iam_list : "${entry.bucket_name}.${entry.role}.${entry.principal}" => entry }
  bucket     = "${var.naming_convention.prefix}${each.value.bucket_name}${var.naming_convention.suffix}"
  role       = each.value.role
  member     = each.value.principal
  depends_on = [google_storage_bucket.buckets]
}

# Description: This file contains the lifecycle rules for the buckets
resource "google_storage_bucket" "buckets" {
  for_each = { for bucket_config in var.buckets_config : bucket_config.bucket_name => bucket_config }
  labels   = each.value.labels
  name     = "${var.naming_convention.prefix}${each.value.bucket_name}${var.naming_convention.suffix}"
  location = each.value.location

  force_destroy = false
  project       = var.project_id
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