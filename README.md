# terraform-google-datalake

This Terraform module allows you to configure and deploy a data lake with:
- One or more GCS buckets
- Lifecycle rules set for those buckets
- Naming conventions
- IAM bindings for those buckets
- Notifications
- Quarantine bucket

## Usage

### Basic

```yaml
buckets_config:
  - bucket_name: "minimum-bucket"
    location: "europe-west1"
    regex_validation: ".*" 
```

### IAM Rules

```yaml
buckets_config:
  - bucket_name: "standard-bucket"
    labels: {"env": "prod", "team": "data"}
    location: "europe-west1"
    iam_rules:
      - role: "roles/storage.editor"
        principals: ["user:username@domain.com"]
      - role: "roles/storage.objectAdmin"
        principals: ["serviceAccount:username@domain.com"]
    regex_validation: ".*"
```

### Naming convention
⚠️ Need to be change in main.tf
```hcl

locals {
  project_id = "<PROJECT_ID>" # Replace this with your actual project id
}

provider "google" {
  project               = local.project_id
  user_project_override = true
  billing_project       = local.project_id
}

# Used to generate a random string to use as a suffix for the bucket names.
# Only required if you want a special naming convention.
resource "random_string" "suffix" {
  length  = 4
  upper   = false
  special = false
}

module "datalake" {
  source = "artefactory/datalake/google"
  project_id = local.project_id

  # Optional: defines the naming convention to use for the buckets created by the module.
  naming_convention = {
    "prefix" : "${local.project_id}-"
    "suffix" : "-${random_string.suffix.result}"
  }
  
  buckets_config = yamldecode(file("./config.yaml"))["buckets_config"]

}

```

### Lifecycle rules

⚠️ Please note that `bucket_configs.autoclass` has to be put to `false` to configure custom
lifecycle rules on your bucket.

```yaml
buckets_config:
  - bucket_name: "standard-bucket"
    location: "europe-west1"
    lifecycle_rules:
      - delay: 30
        storage_class: "NEARLINE"
      - delay: 90
        storage_class: "COLDLINE"
      - delay: 365
        storage_class: "ARCHIVE"
    regex_validation: ".*"
```

## Requirements

* ```Storage Admin: roles/storage.admin```
* ```Pub sub admin: roles/pubsub.admin```

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_pubsub_topic.notification_topic](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_topic) | resource |
| [google_pubsub_topic_iam_binding.bind_gcs_svc_acc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_topic_iam_binding) | resource |
| [google_storage_bucket.buckets](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket) | resource |
| [google_storage_bucket_iam_member.member](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_member) | resource |
| [google_storage_notification.notification](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_notification) | resource |
| [google_storage_project_service_account.gcs_account](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/storage_project_service_account) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_buckets_config"></a> [buckets\_config](#input\_buckets\_config) | Data lake configuration per bucket | <pre>list(<br>    object({<br>      bucket_name = string<br>      autoclass   = optional(bool, true)<br>      lifecycle_rules = optional(list(<br>        object({<br>          delay         = number<br>          storage_class = string<br>        })<br>      ), [])<br>      iam_rules = optional(list(<br>        object({<br>          role       = string<br>          principals = list(string)<br>        })<br>      ), [])<br>      notification_topic = optional(string, null)<br>      regex_validation   = optional(string, ".*")<br>    })<br>  )</pre> | n/a | yes |
| <a name="input_labels"></a> [labels](#input\_labels) | Bucket labels | `map(string)` | `{}` | no |
| <a name="input_location"></a> [location](#input\_location) | GCP location | `string` | `"europe-west1"` | no |
| <a name="input_naming_convention"></a> [naming\_convention](#input\_naming\_convention) | Naming convention for each bucket | <pre>object(<br>    {<br>      prefix = string<br>      suffix = string<br>    }<br>  )</pre> | <pre>{<br>  "prefix": "",<br>  "suffix": ""<br>}</pre> | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | GCP project id | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_buckets"></a> [buckets](#output\_buckets) | Bucket resources as list. |
