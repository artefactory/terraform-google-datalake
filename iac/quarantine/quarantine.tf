# This file contains the quarantine bucket and the quarantine function
resource "google_storage_bucket" "quarantine_bucket" {
  for_each = tomap({ for bucket_config in var.buckets_config : bucket_config.bucket_name => bucket_config if bucket_config.regex_validation != ".*" })

  name                        = "${var.naming_convention.prefix}${each.value.bucket_name}${var.naming_convention.suffix}-quarantine"
  location                    = each.value.location
  force_destroy               = false
  project                     = var.project_id
  storage_class               = "STANDARD"
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
}


resource "google_storage_bucket" "bucket" {
  for_each = tomap({ for bucket_config in var.buckets_config : bucket_config.bucket_name => bucket_config if bucket_config.regex_validation != ".*" })
  name     = "${var.naming_convention.prefix}${each.value.bucket_name}${var.naming_convention.suffix}-archive"
  location = each.value.location
}

data "archive_file" "quarantine_function" {
  type        = "zip"
  # source_dir  = "artefactory/datalake/google/cloud_function"
  source_dir = "/Users/corentin.roineau/Documents/Artefact/03_Projects/04_Intern_Project/terraform-google-datalake/cloud_function"
  output_path = "cloud_function.zip"
}


resource "google_storage_bucket_object" "archive" {
  for_each = google_storage_bucket.bucket
  name   = "${data.archive_file.quarantine_function.output_path}_${data.archive_file.quarantine_function.output_md5}.zip"
  bucket = each.value.name
  source = data.archive_file.quarantine_function.output_path
}

resource "google_service_account" "gcfaccount" {
  account_id   = "gcf-sa"
  display_name = "Test Service Account - used for both the cloud function and eventarc trigger in the test"
}

resource "google_cloudfunctions2_function" "function" {
  for_each = tomap({ for bucket_config in var.buckets_config : bucket_config.bucket_name => bucket_config if bucket_config.notification_topic != null })

  name    = "${each.value.bucket_name}-quarantine-function"
  location  = each.value.location
    service_config {
    max_instance_count = 1
    min_instance_count = 0
    available_memory = "256M"
    timeout_seconds     = 60
    ingress_settings = "ALLOW_INTERNAL_ONLY"
    service_account_email = google_service_account.gcfaccount.email # Replace with your service account email
    }
  build_config {
    runtime = "python312"
    entry_point = "main"
    environment_variables = {
      REGEX_VALIDATION = each.value.regex_validation
    }
    source {
       storage_source {
      # The source code location now uses a Cloud Storage bucket and object directly
      bucket = google_storage_bucket.bucket[each.key].name
      object = google_storage_bucket_object.archive[each.key].name
       }
    }
  }

  event_trigger {
    event_type = "google.cloud.pubsub.topic.v1.messagePublished"
    pubsub_topic   = "projects/sandbox-cofact-datalake-ad8d/topics/${each.value.bucket_name}-${each.value.notification_topic}"
    retry_policy = "RETRY_POLICY_DO_NOT_RETRY"
  }
}