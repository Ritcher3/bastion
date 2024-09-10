################################################################################
# Resources
################################################################################

resource "aws_iam_instance_profile" "bastion_host_profile" {
  name = var.bastion_host_profile
  role = aws_iam_role.bastion_iam_role.id
  tags = var.tags
}

resource "aws_s3_bucket" "bastion_logs" {
  count = var.create_bastion_logs_bucket ? 1 : 0
  bucket = var.bucket_name
 
  tags = {
    Name        = "bastion_logs"
    Environment = "prod"
  }
}

resource "aws_iam_role" "bastion_iam_role" {
  name                 = var.bastion_iam_role
  assume_role_policy   = data.aws_iam_policy_document.assume_policy_document.json
  permissions_boundary = var.bastion_iam_permissions_boundary
}


resource "aws_iam_role_policy" "iam_bastion_policy" {
  name   = "custom-bastion-policy"
  role   = aws_iam_role.bastion_iam_role.id
  policy = data.aws_iam_policy_document.bastion_role_policy.json
}

resource "aws_launch_template" "bastion_launch_template" {
  name_prefix            = "${var.name_prefix}-bastion-"
  image_id               = var.bastion_ami != "" ? var.bastion_ami : data.aws_ami.amazon-linux-2.id
  instance_type          = var.instance_type
  update_default_version = true
  monitoring {
    enabled = true
  }
  network_interfaces {
    associate_public_ip_address = var.associate_public_ip_address
    security_groups             = [aws_security_group.bastion.id]
    delete_on_termination       = true
  }
  iam_instance_profile {
    name = aws_iam_instance_profile.bastion_host_profile.name
  }
  key_name = data.aws_key_pair.bastion.key_name

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    aws_region              = var.region
    bucket_name             = var.bucket_name
    extra_user_data_content = var.extra_user_data_content
    allow_ssh_commands      = lower(var.allow_ssh_commands)
    public_ssh_port         = var.public_ssh_port
    sync_logs_cron_job      = var.enable_logs_s3_sync ? "*/5 * * * * /usr/bin/bastion/sync_s3" : ""
  }))

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = var.disk_size
      volume_type           = "gp2"
      delete_on_termination = true
      encrypted             = var.disk_encrypt
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags          = merge(tomap({ "Name" = var.aws_launch_template_name }), merge(var.tags))
  }

  tag_specifications {
    resource_type = "volume"
    tags          = merge(tomap({ "Name" = var.aws_launch_template_name }), merge(var.tags))
  }

  metadata_options {
    http_endpoint          = var.http_endpoint ? "enabled" : "disabled"
    http_tokens            = var.use_imds_v2 ? "required" : "optional"
    http_protocol_ipv6     = var.enable_http_protocol_ipv6 ? "enabled" : "disabled"
    instance_metadata_tags = var.enable_instance_metadata_tags ? "enabled" : "disabled"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "bastion" {
  name_prefix = "${var.name_prefix}-bastion-ssh-"
  vpc_id      = var.vpc_id
}

resource "tls_private_key" "bastion_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "bastion_key" {
  key_name   = "bastion-key"
  public_key = tls_private_key.bastion_key.public_key_openssh
}

resource "aws_autoscaling_group" "bastion" {
  name_prefix         = var.name_prefix
  vpc_zone_identifier = var.public_subnets

  launch_template {
    id = aws_launch_template.bastion_launch_template.id
  }
  desired_capacity = var.bastion_instance_count
  max_size         = var.bastion_instance_count
  min_size         = var.bastion_instance_count

}

resource "aws_security_group_rule" "ingress_ssh" {
  type              = "ingress"
  from_port         = var.private_ssh_port
  to_port           = var.private_ssh_port
  protocol          = "tcp"
  cidr_blocks       = var.cidrs
  security_group_id = aws_security_group.bastion.id
}

resource "aws_security_group_rule" "egress_ssh" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = var.cidrs
  security_group_id = aws_security_group.bastion.id
}