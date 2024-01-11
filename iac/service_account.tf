resource "google_service_account" "gcfaccount" {
  account_id   = "gcf-sa"
  display_name = "Service Account - used for both the cloud function and eventarc trigger"
}

data "google_storage_project_service_account" "gcs_account" {
}

resource "google_project_iam_member" "gcs-pubsub-publishing" {
  project = var.project_id
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:${data.google_storage_project_service_account.gcs_account.email_address}"
}

resource "google_project_iam_member" "gcf_iam_bindings" {
  for_each = toset([
    "roles/run.invoker",
    "roles/eventarc.eventReceiver"
  ])
  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.gcfaccount.email}"
  depends_on = [google_service_account.gcfaccount]
}