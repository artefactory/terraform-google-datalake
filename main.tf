resource "google_storage_bucket" "buckets" {
  for_each = toset(var.buckets)

  name     = "${var.naming_convention.prefix}-${each.value}-${var.naming_convention.suffix}"
  location = var.location

  force_destroy = false
  project       = var.project_id
  storage_class = "STANDARD"

  dynamic "lifecycle_rule" {
    for_each = var.lifecycle_rules

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
