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


## Input

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| project_id | GCP project ID | `string` | n/as | yes |
| location  | GCP location  | `string` | `europe-west1`  | no |
| labels | Bucket labels | `map(string)` | `{}` | no |
| buckets_config | Main config of the buckets to create | `list(string)`  | n/a | yes |
| lifecycle_rules | Lifecycle rules to define for each bucket | `list(object({delay = number storage_class = string})) ` | `[{"delay" : 60,"storage_class" : "ARCHIVE",}] ` | no |
| naming convention | Naming convention for each bucket | `object({prefix= string suffix=string})` | `{"prefix" : "", "suffix" : ""}` | no |


## Output

| Name    | Description               |
|---------|---------------------------|
| buckets | Bucket resources as list. |

