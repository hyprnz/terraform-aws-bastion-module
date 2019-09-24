locals {
  s3_bucket_name = "${format("%s.%s", var.s3_bucket_name, var.s3_bucket_namespace)}"
}

resource "aws_s3_bucket" "this" {
  bucket = "${local.s3_bucket_name}"
  region = "${var.bucket_region}"
  acl    = "${var.acl}"

  versioning {
    enabled = true
  }
}

resource "aws_s3_bucket_object" "this" {
  count = "${length(var.objects)}"

  bucket  = "${aws_s3_bucket.mod.id}"
  key     = "${element(var.objects, count.index)}"
  content = "${file("${path.cwd}/objects/${element(var.objects, count.index)}")}"

  depends_on = ["aws_s3_bucket.this"]
}
