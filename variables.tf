variable "project_id" {
  description = "GCP project id"
  type        = string
}

variable "location" {
  description = "GCP location"
  type        = string
  default     = "europe-west1"
}

variable "labels" {
  description = "Bucket labels"
  type        = map(string)
  default     = {}
}

variable "buckets_config" {
  description = "Data lake configuration per buckets"
  type = list(
    object({
      bucket_name = string
      autoclass   = optional(bool, true)
      lifecycle_rules = optional(list( # if autoclass is false or unspecified
        object({
          delay         = number
          storage_class = string
        })
      ), [])
      iam_rules = optional(list(
        object({
          roles      = string
          principals = list(string)
        })
      ), [])
      notification_topic = optional(string, null)
      regex_validation   = optional(string, ".*")
    })
  )
  validation {
    condition = alltrue([
      for bucket_config in var.buckets_config : bucket_config.autoclass == true && length(bucket_config.lifecycle_rules) == 0 || bucket_config.autoclass == false && length(bucket_config.lifecycle_rules) != 0
    ])
    error_message = "Autoclass cannot be true while lifecyle_rules are defined AND Autoclass cannot be false while lifecycle_rules are empty"
  }
}

variable "naming_convention" {
  description = "Naming convention for each bucket"
  type = object(
    {
      prefix = string
      suffix = string
    }
  )
  default = {
    prefix = ""
    suffix = ""
  }
}
