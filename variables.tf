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

variable "buckets" {
  description = "Name of the buckets to create"
  type        = list(string)
}

variable "lifecycle_rules" {
  description = "Lifecycle rules to define for each bucket"
  type = list(
    object(
      {
        delay         = number
        storage_class = string
      }
    )
  )
  default = [
    {
      "delay" : 60,
      "storage_class" : "ARCHIVE",
    }
  ]
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

variable "storage_admins" {
  description = "Liste of members that can create/delete/edit a bucket"
  type        = list(string)
  default     = []
}

variable "object_admins" {
  description = "Liste of members that can create/delete an object"
  type        = list(string)
  default     = []
}

variable "object_viewers" {
  description = "List of members that can view objects"
  type        = list(string)
  default     = []
}

variable "notification_topic_id" {
  description = "ID of the topic that will receive notifications concerning objects"
  type        = string
  default     = ""
}