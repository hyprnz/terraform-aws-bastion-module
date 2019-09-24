data "aws_iam_policy_document" "s3_bastion" {
  statement {
    sid = "AllowBastionAccessToKeysBucket"

    actions = [
      "s3:ListBucket",
    ]

    resources = [
      "arn:aws:s3:::${local.s3_bucket_name}",
    ]
  }

  statement {
    sid = "AllowGetS3ActionsOnTerraformBucketPath"

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "arn:aws:s3:::${local.s3_bucket_name}/*",
    ]
  }
}

resource "aws_iam_policy" "bastion_reader" {
  name        = "BastionKeysReadAccess"
  policy      = "${data.aws_iam_policy_document.s3_bastion.json}"
  description = "Grants permissions to read keys in bastion keys bucket"
}

resource "aws_iam_role" "bastion_role" {
  name               = "BastionInstanceRole"
}

resource "aws_iam_role_policy_attachment" "role_policy" {
  role       = "${aws_iam_role.bastion_role.name}"
  policy_arn = "${aws_iam_policy.bastion_reader.arn}" 
}
