variable "name" {
  description = "Name of Bastion"
}

variable "s3_bucket_namespace" {
  description = "The namespace to append to the bucket name in an attempt to make it globally unique"
}

variable "instance_type" {
  default = "t3.nano"
}

variable "acl" {
  description = "The canned ACL to apply. Defaults to 'private'"
  default     = "private"
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
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "vpc_id" {
  description = "ID of the VPC for bastion resources"
}

variable "subnet_ids" {
  description = "A list of subnet ids for bastion resources"
  type        = list(string)
}

variable "keys_to_prime" {
  description = "A list of public key files to upload. Must be in the keys directory"
  type        = list(string)
  default     = []
}

variable "asg_tags" {
  description = "Specific tags to add to the ASG - Should include `propagate = true` key"
  type        = list(map(string))
  default     = []
}

variable "tags" {
  description = "Tags to add to all bastion resources - except the ASG"
  type        = map(string)
  default     = {}
}

