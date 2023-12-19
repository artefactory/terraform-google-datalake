# This file contains the notification configuration for the buckets

resource "google_storage_notification" "notification" {
  for_each       = tomap({ for bucket_config in var.buckets_config : bucket_config.bucket_name => bucket_config if bucket_config.notification_topic != null })
  bucket         = "${var.naming_convention.prefix}${each.value.bucket_name}${var.naming_convention.suffix}"
  payload_format = "JSON_API_V1"
  topic          = "${each.value.bucket_name}-${each.value.notification_topic}"
  event_types    = ["OBJECT_FINALIZE", "OBJECT_DELETE", "OBJECT_METADATA_UPDATE"]
  depends_on     = [google_pubsub_topic_iam_member.bind_gcs_svc_acc]
}

data "google_storage_project_service_account" "gcs_account" {
  project = var.project_id
}

resource "google_pubsub_topic_iam_member" "bind_gcs_svc_acc" {
  for_each = google_pubsub_topic.notification_topic
  topic    = each.value.id
  role     = "roles/pubsub.publisher"
  member   = "serviceAccount:${data.google_storage_project_service_account.gcs_account.email_address}"
}

resource "google_pubsub_topic" "notification_topic" {
  for_each = tomap({ for bucket_config in var.buckets_config : bucket_config.bucket_name => bucket_config if bucket_config.notification_topic != null })
  project  = var.project_id
  name     = "${each.value.bucket_name}-${each.value.notification_topic}"
}
