resource "aws_s3_bucket" "bastion" {
  bucket = "${local.s3_full_bucket_name}"
  acl    = "${var.acl}"

  versioning {
    enabled = true
  }
}

resource "aws_s3_bucket_object" "bastion" {
  count = "${length(var.keys_to_prime)}"

  bucket  = "${aws_s3_bucket.bastion.id}"
  key     = "${element(var.keys_to_prime, count.index)}"
  content = "${file("${path.cwd}/keys/${element(var.keys_to_prime, count.index)}")}"

  depends_on = ["aws_s3_bucket.bastion"]
}
