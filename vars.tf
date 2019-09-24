variable "name" {
  description = "Name of Bastion"
}


variable "instance_type" {
  default = "t3.nano"
}

variable "user_data_file" {
  default = "user_data.sh"
}

variable "s3_bucket_name" {
  default = "bastion-keys"
}

variable "s3_bucket_uri" {
  default = ""
}

variable "ssh_user" {
  default = "ubuntu"
}

variable "enable_hourly_cron_updates" {
  default = "false"
}

variable "keys_update_frequency" {
  default = "5,20,35,50 * * * *"
}

variable "additional_user_data_script" {
  default = "data"
}

variable "ingress_source_cidrs" {
  description = "A list of source cidr ranges to allow connection to the bastion"
  default     = ["0.0.0.0/0"]
}

variable "vpc_id" {
  description = "ID of the VPC for bastion resources"
}

variable "subnet_ids" {
  description = "A list of subnet ids for bastion resources"
  type        = "list"
}

