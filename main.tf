resource "aws_security_group" "bastion" {
  name        = var.name
  vpc_id      = var.vpc_id
  description = "Bastion security group (only SSH inbound access is allowed)"

  tags = {
    Name = var.name
  }

  ingress {
    protocol  = "tcp"
    from_port = 22
    to_port   = 22

    cidr_blocks = var.ingress_source_cidrs
  }

  egress {
    protocol  = -1
    from_port = 0
    to_port   = 0

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  lifecycle {
    create_before_destroy = true
  }
}

data "template_file" "user_data" {
  template = file("${path.module}/${var.user_data_file}")

  vars = {
    s3_bucket_name              = local.s3_full_bucket_name
    s3_bucket_uri               = var.s3_bucket_uri
    ssh_user                    = var.ssh_user
    keys_update_frequency       = var.keys_update_frequency
    enable_hourly_cron_updates  = var.enable_hourly_cron_updates
    additional_user_data_script = var.additional_user_data_script
  }
}

/* Launch Configuration */
resource "aws_launch_configuration" "bastion" {
  name_prefix = var.name

  image_id = data.aws_ami.ubuntu.id

  instance_type = var.instance_type
  user_data     = data.template_file.user_data.rendered

  security_groups = [aws_security_group.bastion.id]

  iam_instance_profile = aws_iam_instance_profile.default.name

  lifecycle {
    create_before_destroy = true
  }
}

/* Autoscaling Group */
resource "aws_autoscaling_group" "bastion" {
  name = var.name

  vpc_zone_identifier = [var.subnet_ids[0]]

  desired_capacity          = "1"
  min_size                  = "0"
  max_size                  = "1"
  health_check_grace_period = "60"
  health_check_type         = "EC2"
  force_delete              = false
  wait_for_capacity_timeout = 0
  launch_configuration      = aws_launch_configuration.bastion.name

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances",
  ]

  # TF-UPGRADE-TODO: In Terraform v0.10 and earlier, it was sometimes necessary to
  # force an interpolation expression to be interpreted as a list by wrapping it
  # in an extra set of list brackets. That form was supported for compatibility in
  # v0.11, but is no longer supported in Terraform v0.12.
  #
  # If the expression in the following list itself returns a list, remove the
  # brackets to avoid interpretation as a list of lists. If the expression
  # returns a single list item then leave it as-is and remove this TODO comment.
  tags = concat(
    [
      {
        key                 = "Owner"
        value               = "Bastion"
        propagate_at_launch = true
      },
      {
        key                 = "Name"
        value               = var.name
        propagate_at_launch = true
      },
    ],
    var.asg_tags,
  )



  lifecycle {
    create_before_destroy = true
  }
}

