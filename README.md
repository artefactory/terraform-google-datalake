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
  bucket_configs = [
    {"bucket_name" : "source-a"}
    {"bucket_name" : "source-b"}
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
  bucket_configs = [
    {
        "bucket_name" : "source-A"
        "iam_rules" : [
            { 
                "role" : "roles/editor",
                "principals" : ["user:user@domain.com"] 
            },
            { 
                "role" : "roles/viewer",
                "principals" : ["user:user_2@domain.com"] 
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

resource "random_string" "suffix" {
  length  = 4
  upper   = false
  special = false
}

module "datalake" {
  source     = "artefactory/datalake/google"
  project_id = local.project_id
  bucket_configs = [
    {"bucket_name" : "source-a"}
  ]
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
  bucket_configs = [
    {
        "bucket_name" : "source-A"
        "autoclass" : false,
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


## Input

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| project_id | GCP project ID | `string` | n/as | yes |
| location  | GCP location  | `string` | `europe-west1`  | no |
| labels | Bucket labels | `map(string)` | `{}` | no |
| buckets | Name of the buckets to create | `list(string)`  | n/a | yes |
| lifecycle_rules | Lifecycle rules to define for each bucket | `list(object({delay = number storage_class = string})) ` | `[{"delay" : 60,"storage_class" : "ARCHIVE",}] ` | no |
| naming convention | Naming convention for each bucket | `object({prefix= string suffix=string})` | `{"prefix" : "", "suffix" : ""}` | no |


## Output

| Name    | Description               |
|---------|---------------------------|
| buckets | Bucket resources as list. |

