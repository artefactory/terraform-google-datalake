locals {
  filtered_buckets_config = { for bucket_config in var.buckets_config : bucket_config.bucket_name => bucket_config if bucket_config.regex_validation != ".*" }
}

resource "google_storage_bucket" "quarantine_bucket" {
  for_each = tomap(local.filtered_buckets_config)
  name                        = "${var.naming_convention.prefix}${each.value.bucket_name}${var.naming_convention.suffix}-quarantine"
  location                    = each.value.location
  force_destroy               = false
  project                     = var.project_id
  storage_class               = "STANDARD"
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
} 


resource "google_storage_bucket" "archive_bucket" {
  for_each = tomap(local.filtered_buckets_config)
  name     = "${var.naming_convention.prefix}${each.value.bucket_name}${var.naming_convention.suffix}-archive"
  location = each.value.location
}


resource "google_storage_bucket_iam_binding" "bucket_iam" {
  for_each = tomap(local.filtered_buckets_config)
  bucket   = "${var.naming_convention.prefix}${each.value.bucket_name}${var.naming_convention.suffix}"
  role     = "roles/storage.admin"
  members  = ["serviceAccount:${google_service_account.gcfaccount.email}"]
  depends_on = [google_service_account.gcfaccount]
}

resource "google_storage_bucket_iam_binding" "quarantine_bucket_iam" {
  for_each = tomap(local.filtered_buckets_config)
  bucket   = "${var.naming_convention.prefix}${each.value.bucket_name}${var.naming_convention.suffix}-quarantine"
  role     = "roles/storage.admin"
  members  = ["serviceAccount:${google_service_account.gcfaccount.email}"]
  depends_on = [google_storage_bucket.quarantine_bucket]
}



data "archive_file" "quarantine_function" {
  type = "zip"
  source_dir  = "artefactory/datalake/google/cloud_function"
  output_path = "cloud_function.zip"
}


resource "google_storage_bucket_object" "archive" {
  for_each = google_storage_bucket.archive_bucket
  name     = "${data.archive_file.quarantine_function.output_path}_${data.archive_file.quarantine_function.output_md5}.zip"
  bucket   = each.value.name
  source   = data.archive_file.quarantine_function.output_path
}


resource "google_cloudfunctions2_function" "function" {
  for_each = tomap(local.filtered_buckets_config)
  name     = "${each.value.bucket_name}-quarantine-function"
  location = each.value.location
  service_config {
    environment_variables = {
      REGEX_VALIDATION = each.value.regex_validation
    }
    max_instance_count    = 1
    min_instance_count    = 0
    available_memory      = "256M"
    timeout_seconds       = 60
    ingress_settings      = "ALLOW_INTERNAL_ONLY"
    service_account_email = google_service_account.gcfaccount.email
  }
  build_config {
    runtime     = "python312"
    entry_point = "main"

    source {
      storage_source {
        bucket = google_storage_bucket.archive_bucket[each.key].name
        object = google_storage_bucket_object.archive[each.key].name
      }
    }
  }

  event_trigger {
    trigger_region        = "europe-west1" # The trigger must be in the same location as the bucket
    event_type            = "google.cloud.storage.object.v1.finalized"
    retry_policy          = "RETRY_POLICY_RETRY"
    service_account_email = google_service_account.gcfaccount.email
    event_filters {
      attribute = "bucket"
      value     = "${var.naming_convention.prefix}${each.value.bucket_name}${var.naming_convention.suffix}"
    }

  }
  depends_on = [ google_storage_bucket_iam_binding.quarantine_bucket_iam ]
}
