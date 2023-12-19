
locals {
  buckets_config = yamldecode(file("./config.yaml"))["buckets_config"]
}

module "bucket" {
  source = "./bucket"
  buckets_config = local.buckets_config
  project_id = var.project_id
  naming_convention = var.naming_convention
}

module "notification" {
  source = "./notification"
  buckets_config = local.buckets_config
  project_id = var.project_id
  naming_convention = var.naming_convention
  depends_on = [module.quarantine]
}

module "quarantine" {
  source = "./quarantine"
  buckets_config = local.buckets_config
  project_id = var.project_id
  naming_convention = var.naming_convention
  depends_on = [module.bucket]
}


