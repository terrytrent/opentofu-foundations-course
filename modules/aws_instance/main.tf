data "aws_vpc" "default" {
  filter {
    name   = "isDefault"
    values = ["true"]
  }
}

data "http" "myip" {
  url = "https://ipv4.icanhazip.com"
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

  }
}

data "aws_iam_policy_document" "parameter_store" {
  statement {
    effect = "Allow"
    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters"
    ]
    resources = ["arn:aws:ssm:us-east-1:${data.aws_vpc.default.owner_id}:parameter/*"]
  }
}

resource "aws_iam_role" "instance_role" {
  name               = "${var.name_prefix}-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json

  inline_policy {
    name   = "parameter_store_policy"
    policy = data.aws_iam_policy_document.parameter_store.json
  }
}

resource "aws_iam_instance_profile" "instance_profile" {
  name = "${var.name_prefix}-profile"
  role = aws_iam_role.instance_role.name
}

resource "aws_instance" "this" {
  depends_on = [
    aws_iam_instance_profile.instance_profile,
    aws_security_group.wordpress,
    aws_security_group.ssh,
    aws_key_pair.deployer,
  ]
  ami           = "${var.ami}"
  instance_type = "${var.instance_type}"

  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.wordpress.id, aws_security_group.ssh.id]

  key_name = aws_key_pair.deployer.key_name

  iam_instance_profile = aws_iam_instance_profile.instance_profile.name

  user_data_replace_on_change = true
  user_data_base64 = var.user_data_base64

  tags = var.tags
}

resource "aws_security_group" "ssh" {
  name = "${var.name_prefix}-ssh"

  ingress {
    description = "SSH from local"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.response_body)}/32"]
  }
}

resource "aws_security_group" "wordpress" {
  name        = "${var.name_prefix}-wordpress-${random_id.security_group_wordpress.hex}"
  description = "Allow HTTP inbound traffic"

  lifecycle {
    create_before_destroy = true
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.response_body)}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}