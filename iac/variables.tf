variable "project_id" {
  description = "GCP project id"
  type        = string
}

variable "location" {
  description = "GCP location"
  type        = string
  default     = "europe-west1"
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

variable "buckets_config" {
  description = "Configuration for GCP buckets"
  type = list(object({
    bucket_name = string
    autoclass   = optional(bool, true)
    labels      = optional(map(string), {})
    location    = string
    versioning  = optional(bool)
    
    retention_policy = optional(object({
      is_locked        = optional(bool)
      retention_period = optional(number)
    }), null)

    lifecycle_rules = optional(list(object({
      delay         = number
      storage_class = string
    })), [])

    iam_rules = optional(list(object({
      role       = string
      principals = list(string)
    })), [])

    regex_validation = optional(string)
  }))

  default = []
}
