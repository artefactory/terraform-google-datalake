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
      name      = string
      autoclass = bool
      lifecycle_rules = optional(list( # if autoclass is false
        object({
          delay         = number
          storage_class = string
        })
      ))
      iam_rules = optional(list(
        object({
          roles      = string
          principals = list(string)
        })
      ))
      notification_topic = optional(string)
      regex_validation   = optional(string)
    })
  )
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
