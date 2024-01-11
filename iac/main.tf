locals {
  buckets_config = yamldecode(file("./config.yaml"))["buckets_config"]
}