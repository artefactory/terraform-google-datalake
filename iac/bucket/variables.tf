# Description: bucket variables

variable "naming_convention" {
  description = "Naming convention to use for the buckets created by the module"  
}

variable "buckets_config" {
  description = "List of buckets to create"
}

variable "project_id" {
  description = "Project ID to use for the buckets"
}