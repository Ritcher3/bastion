variable "vpc_id" {
  type        = string
  description = "VPC ID where we'll deploy the bastion"
}

variable "region" {
  type        = string
  description = "Region to deploy bastion"
  default     = "data.aws_region.current.name" #defaults to whatever region is currently selected
}


variable "create_bastion_logs_bucket" {
  type        = bool
  description = "Bucket name where the bastion will store the logs"
  default     = ""
}

variable "bucket_name" {
  type        = string
  description = "Bucket name where the bastion will store the logs"
}

variable "bastion_host_key_pair" {
  type        = string
  description = "Select the key pair to use to launch the bastion host"
}

variable "bastion_ami" {
  type        = string
  description = "The AMI that the Bastion Host will use."
  default     = ""
}

variable "allow_ssh_commands" {
  type        = bool
  description = "Allows the SSH user to execute one-off commands. Pass true to enable. Warning: These commands are not logged and increase the vulnerability of the system. Use at your own discretion."
  default     = false
}

variable "private_ssh_port" {
  type        = number
  description = "Set the SSH port to use between the bastion and private instance"
  default     = 22
}

variable "log_auto_clean" {
  type        = bool
  description = "Enable or disable the lifecycle"
  default     = true
}

variable "cidrs" {
  type        = list(string)
  description = "List of CIDRs that can access the bastion. Default: 0.0.0.0/0"

  default = [
    "0.0.0.0/0",
  ]
}

variable "bucket_versioning" {
  type        = bool
  description = "Enable bucket versioning or not"
  default     = true

}

variable "bucket_force_destroy" {
  type        = bool
  description = "The bucket and all objects should be destroyed when using true"
  default     = false

}

variable "bastion_security_group_id" {
  type        = string
  description = "Custom security group to use"
  default     = ""
}

variable "bastion_instance_count" {
  type        = number
  description = "Number of instances to launch"
  default     = 1
}

  data "aws_vpc" "main" {
   id = var.vpc_id
 }

variable "aws_launch_template_name" {
  type        = string
  description = "Bastion launch template name"
}

variable "instance_type" {
  type        = string
  description = "Instance size of the bastion"
  default     = "t3.nano"
}

variable "public_ssh_port" {
  type        = number
  description = "Set the SSH port to use from desktop to the bastion"
  default     = 22
}

variable "name_prefix" {
  type        = string
  description = "prefix used for naming resources"
}

# variable "public_subnets" {
#   type        = list(string)
#   description = "Classless Inter-Domain Routing ranges for public subnets."
# }

variable "associate_public_ip_address" {
  type        = bool
  description = "Asscociate the Bastion host with a public ip"
  default     = true

}

variable "extra_user_data_content" {
  type        = string
  description = "Additional scripting to pass to the bastion host. For example, this can include installing PostgreSQL for the `psql` command."
  default     = ""
}

variable "enable_logs_s3_sync" {
  type        = bool
  description = "Enable cron job to copy logs to S3"
  default     = true
}

variable "disk_size" {
  type        = number
  description = "Root RBS size in GB"
  default     = "8"
}

variable "disk_encrypt" {
  type        = bool
  description = "Whether the ebs volume is encrypted or not"
  default     = true
}


variable "tags" {
  type        = map(string)
  description = "Default tags attached to all resources."
  default = {
    ServiceType = "bastion-ssh"
  }
}

variable "use_imds_v2" {
  type        = bool
  description = "Use (IMDSv2) Service"
  default     = false
}

variable "enable_instance_metadata_tags" {
  type        = bool
  description = "Enables or disables access to instance tags from the instance metadata service"
  default     = false

}

variable "enable_http_protocol_ipv6" {
  type        = bool
  description = "Enables or disables the IPv6 endpoint for the instance metadata service"
  default     = false
}

variable "kms_enable_key_rotation" {
  type        = bool
  description = "Enables key rotation"
  default     = false
}

# variable "bastion_host_profile" {
#   type        = string
#   description = "Name your instance profile"
# }

variable "bastion_iam_role" {
  type        = string
  description = "role of bastion"
  default     = "value"
}

variable "bastion_iam_permissions_boundary" {
  type        = string
  description = "IAM Role Permissions Boundary to constrain the bastion host role"
  default     = ""
}

# variable "iam_instance_profile" {
#   type        = string
#   description = "Iam profile"
# }

variable "http_endpoint" {
  type        = bool
  description = "Whether the metadata service is available"
  default     = true
}

 variable "asg_name" {
  type        = string
  description = "ASG name"
 }

variable "availability_zones" {
  type        = string
  description = "AZ of bastion"
  default     = "us-west-2a"
}

variable "tag_all" {
  type        = string
  description = "tags all resources"
  default     = ""
}