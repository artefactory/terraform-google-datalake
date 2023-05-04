resource "google_storage_bucket" "buckets" {
  for_each = tomap( {for bucket_config in var.buckets_config : bucket_config.bucket_name => bucket_config} )

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


resource "google_storage_bucket_iam_member" "member" {
  for_each = tomap({for bucket_config in var.buckets_config : {for iam_rule in bucket_config.iam_rules: {for principal in iam_rule.principals : "${bucket_config.bucket_name}.${iam_rules.role}.${principal}" => [bucket_config.bucket_name, iam_rules.role, principal] }}})
  bucket = each.value[0]
  role = each.value[1]
  member = each.value[2]
}