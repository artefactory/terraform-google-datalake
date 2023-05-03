# terraform-google-datalake

This Terraform module allows you to configure and deploy a data lake with:
- One or more GCS buckets
- Lifecycle rules set for those buckets
- Naming conventions

⏳ Incoming features:
- IAM bindings for those buckets
- Notifications
- Quarantine bucket
...

## Requirements: 
User or service account credentials with the following roles must be used to set the IAM policies to the resources: 
* ```Storage Admin: roles/storage.admin```
* ```Pub sub admin: roles/pubsub.admin````


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
  buckets    = [
    "source-a",
    "source-b"
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
| lifecycle_rules | Lifecycle rules to define for each bucket | `list(object({delay = number storage_class = string})) ` | `[{"delay": 60,"storage_class": "ARCHIVE",}] ` | no |
| naming convention | Naming convention for each bucket | `object({prefix= string suffix=string})` | `{"prefix": "", "suffix": ""}` | no |
|storage admins | The list of storage admins | `list(string)` | `[]` | no |
|object admins | The list of object admins | `list(string)` | `[]` | no |
| object viewers | The list of object viewers | `list(string)` | `[]` | no |
| notification_topic_id | The name of the topic to create and that will receive the notifications of the objects | `string` | `""` | no |

## Output

| Name    | Description               |
|---------|---------------------------|
| buckets | Bucket resources as list. |

