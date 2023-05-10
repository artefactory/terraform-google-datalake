# terraform-google-datalake

This Terraform module allows you to configure and deploy a data lake with:
- One or more GCS buckets
- Lifecycle rules set for those buckets
- Naming conventions
- IAM bindings for those buckets
- Notifications

⏳ Incoming features: 
- Quarantine bucket
...

## Usage

### Basic

```hcl
locals {
  project_id = "PROJECT_ID" # Replace this with your actual project id
}

provider "google" {
  user_project_override = true
  billing_project       = local.project_id
}

module "datalake" {
  source     = "artefactory/datalake/google"
  project_id = local.project_id

  # Main config for all your buckets. Each dictionnary corresponds to one bucket.
  bucket_configs = [
    {
        "bucket_name" : "YOUR_BUCKET"  # Replace this with the name of your bucket.
    }
  ]
}
```

### IAM Rules

```hcl
locals {
  project_id = "PROJECT_ID" # Replace this with your actual project id
}

provider "google" {
  user_project_override = true
  billing_project       = local.project_id
}

module "datalake" {
  source     = "artefactory/datalake/google"
  project_id = local.project_id

  # Main config for all your buckets. Each dictionnary corresponds to one bucket.
  bucket_configs = [
    {
        "bucket_name" : "YOUR_BUCKET", # Replace this with the name of your bucket.

        # Optional : List of maps that define the Identity and Access Management (IAM) roles and principals for this bucket. 
        # More information about GCP roles: https://cloud.google.com/iam/docs/understanding-roles
        "iam_rules" : [
            { 
                "role" : "roles/editor",
                "principals" : ["user:YOUR_USER_MAIL"] 
            },
            { 
                "role" : "roles/viewer",
                "principals" : ["user:YOUR_USER_MAIL"] 
            }
        ]
    }
  ]
}
```

### Naming convention

```hcl
locals {
  project_id = "PROJECT_ID" # Replace this with your actual project id
}

provider "google" {
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
  source     = "artefactory/datalake/google"
  project_id = local.project_id

  # Main config for all your buckets. Each dictionnary corresponds to one bucket.
  bucket_configs = [
    {"bucket_name" : "YOUR_BUCKET"}
  ]

  # Optional: defines the naming convention to use for the buckets created by the module.
  naming_convention = {
    "prefix" : local.project_id
    "suffix" : random_string.suffix.result
  }
}
```

### Lifecycle rules

⚠️ Please note that `bucket_configs.autoclass` has to be put to `false` to configure custom
lifecycle rules on your bucket.

```hcl
locals {
  project_id = "PROJECT_ID" # Replace this with your actual project id
}

provider "google" {
  user_project_override = true
  billing_project       = local.project_id
}

module "datalake" {
  source     = "artefactory/datalake/google"
  project_id = local.project_id

  # Main config for all your buckets. Each dictionnary corresponds to one bucket.
  bucket_configs = [
    {
        "bucket_name" : "YOUR_BUCKET", # Replace this with the name of your bucket.
        "autoclass" : false, # Optional: Default is true. Need to be set to false in order to define lifecycle_rules.

        # Optional: List of maps that define the lifecycle rules for this bucket.
        # More information about lifecycle management: https://cloud.google.com/storage/docs/lifecycle
        "lifecycle_rules" : [
            { 
                "delay" : 60,
                "storage_class" : "ARCHIVE"
            }
        ]
    }
  ]
}
```

## Requirements

No requirements.

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
