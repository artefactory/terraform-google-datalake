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

resource "google_storage_bucket" "buckets" {
  for_each = tomap({ for bucket_config in var.buckets_config : bucket_config.bucket_name => bucket_config })

  labels   = var.labels
  name     = "${var.naming_convention.prefix}${each.value.bucket_name}${var.naming_convention.suffix}"
  location = var.location

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

resource "google_storage_bucket_iam_member" "member" {
  for_each   = { for entry in local.iam_list : "${entry.bucket_name}.${entry.role}.${entry.principal}" => entry }
  bucket     = "${var.naming_convention.prefix}${each.value.bucket_name}${var.naming_convention.suffix}"
  role       = each.value.role
  member     = each.value.principal
  depends_on = [google_storage_bucket.buckets]
}

resource "google_storage_notification" "notification" {
  for_each       = tomap({ for bucket_config in var.buckets_config : bucket_config.bucket_name => bucket_config if bucket_config.notification_topic != null })
  bucket         = "${var.naming_convention.prefix}${each.value.bucket_name}${var.naming_convention.suffix}"
  payload_format = "JSON_API_V1"
  topic          = each.value.notification_topic
  event_types    = ["OBJECT_FINALIZE", "OBJECT_DELETE", "OBJECT_ARCHIVE", "OBJECT_METADATA_UPDATE"]
  depends_on = [google_pubsub_topic_iam_binding.bind_gcs_svc_acc,
  google_storage_bucket.buckets]
}

data "google_storage_project_service_account" "gcs_account" {
  project = var.project_id
}

resource "google_pubsub_topic_iam_binding" "bind_gcs_svc_acc" {
  for_each = google_pubsub_topic.notification_topic
  topic    = each.value.id
  role     = "roles/pubsub.publisher"
  members  = ["serviceAccount:${data.google_storage_project_service_account.gcs_account.email_address}"]
}


resource "google_pubsub_topic" "notification_topic" {
  for_each = tomap({ for bucket_config in var.buckets_config : bucket_config.bucket_name => bucket_config if bucket_config.notification_topic != null })
  project  = var.project_id
  name     = each.value.notification_topic
}