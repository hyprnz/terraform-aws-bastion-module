resource "aws_security_group" "bastion" {
  name        = "${var.name}"
  vpc_id      = "${var.vpc.id}"
  description = "Bastion security group (only SSH inbound access is allowed)"

  tags {
    Name = "${var.name}"
  }

  ingress {
    protocol  = "tcp"
    from_port = 22
    to_port   = 22

    cidr_blocks = "${var.ingress_source_cidrs}"
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
  template = "${file("${path.module}/${var.user_data_file}")}"

  vars {
    s3_bucket_name              = "${var.s3_bucket_name}"
    s3_bucket_uri               = "${var.s3_bucket_uri}"
    ssh_user                    = "${var.ssh_user}"
    keys_update_frequency       = "${var.keys_update_frequency}"
    enable_hourly_cron_updates  = "${var.enable_hourly_cron_updates}"
    additional_user_data_script = "${var.additional_user_data_script}"
  }
}

/* Launch Configuration */
resource "aws_launch_configuration" "bastion" {
  name_prefix = "${var.name}"

  /* image_id = "${data.aws_ami.linux_ami.id}" */
  image_id = "${data.aws_ami.ubuntu.id}"

  instance_type = "${var.instance_type}"
  user_data     = "${data.template_file.user_data.rendered}"

  security_groups = [
    "${compact(concat(list(aws_security_group.bastion.id), split(",", "${var.security_group_ids}")))}",
  ]

  iam_instance_profile = "${data.terraform_remote_state.iam.s3_readonly_instance_profile_id}"

  lifecycle {
    create_before_destroy = true
  }
}

/* Autoscaling Group */
resource "aws_autoscaling_group" "bastion" {
  name = "${var.name}"

  vpc_zone_identifier = [
    ["${var.subnet_ids}"],
  ]

  desired_capacity          = "1"
  min_size                  = "1"
  max_size                  = "1"
  health_check_grace_period = "60"
  health_check_type         = "EC2"
  force_delete              = false
  wait_for_capacity_timeout = 0
  launch_configuration      = "${aws_launch_configuration.bastion.name}"

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

  tags = "${merge(map("Bastion", format("%s", var.name)), var.asg_tags, var.tags)}"

  lifecycle {
    create_before_destroy = true
  }
}
