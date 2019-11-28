locals {
  s3_full_bucket_name = format("%s.%s", var.s3_bucket_name, var.s3_bucket_namespace)
}

