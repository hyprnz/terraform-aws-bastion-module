data "aws_iam_policy_document" "s3_bastion" {
  statement {
    sid = "AllowBastionAccessToKeysBucket"

    actions = [
      "s3:ListBucket",
    ]

    resources = [
      "arn:aws:s3:::${local.s3_full_bucket_name}",
    ]
  }

  statement {
    sid = "AllowGetS3ActionsOnTerraformBucketPath"

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "arn:aws:s3:::${local.s3_full_bucket_name}/*",
    ]
  }
}

data "aws_iam_policy_document" "assume_from_ec2" {
  statement {
    sid     = "AssumeFromEC2BastionKeysBucket"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "bastion_reader" {
  name        = "BastionKeysReadAccess-${var.name}"
  policy      = "${data.aws_iam_policy_document.s3_bastion.json}"
  description = "Grants permissions to read keys in bastion keys bucket"
}

resource "aws_iam_role" "bastion_role" {
  name               = "BastionInstanceRole-${var.name}"
  assume_role_policy = "${data.aws_iam_policy_document.assume_from_ec2.json}"
}

resource "aws_iam_role_policy_attachment" "role_policy" {
  role       = "${aws_iam_role.bastion_role.name}"
  policy_arn = "${aws_iam_policy.bastion_reader.arn}"
}

resource "aws_iam_instance_profile" "default" {
  name = "BastionInstanceProfile-${var.name}"
  role = "${aws_iam_role.bastion_role.name}"
}