data "aws_vpc" "default" {
  filter {
    name   = "isDefault"
    values = ["true"]
  }
}

locals {
  docker_compose_download_url = [for a in jsondecode(data.http.docker_compose_release_json.response_body)["assets"] : a
  if a["name"] == "docker-compose-linux-x86_64"][0]["browser_download_url"]
  nginx_config = file("${path.module}/templates/nginx.conf")
  docker_compose = file("${path.module}/templates/docker-compose.yml")
  user_data = templatefile(
    "${path.module}/templates/user_data.tftpl",
    {
      "DOCKER_COMPOSE_URL" = "${local.docker_compose_download_url}"
      "DB_HOST"            = "${var.db_host}"
      "IMAGE_NAME"         = "${var.image.name}"
      "IMAGE_TAG"          = "${var.image.tag}"
      "NGINX_CONFIG"       = "${local.nginx_config}"
      "DOCKER_COMPOSE"     = "${local.docker_compose}"
    }
  )
}

data "http" "docker_compose_release_json" {
  url    = "https://api.github.com/repos/docker/compose/releases/latest"
  method = "GET"
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

resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "random_id" "security_group_wordpress" {
  byte_length = 8
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = trimspace(tls_private_key.rsa.public_key_openssh)
}

resource "aws_ssm_parameter" "deployer_ssh_key" {
  name  = "deployer_ssh_key"
  type  = "SecureString"
  value = jsonencode({ private = "${tls_private_key.rsa.private_key_pem}", public = "${tls_private_key.rsa.public_key_openssh}" })

  lifecycle {
    ignore_changes = [
      value
    ]
  }
}

resource "aws_iam_policy" "read_parameter_store" {
  name = "read_parameter_store"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters"
        ]
        Resource = ["arn:aws:ssm:us-east-1:${data.aws_vpc.default.owner_id}:parameter/*"]
    }]
  })
}

resource "aws_iam_role" "instance_role" {
  name               = "${var.name_prefix}-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    aws_iam_policy.read_parameter_store.arn
  ]
}

resource "aws_iam_instance_profile" "instance_profile" {
  name = "${var.name_prefix}-profile"
  role = aws_iam_role.instance_role.name
}

resource "terraform_data" "user_data_replace" {
  input = sha1(local.user_data)
}

resource "aws_launch_template" "this" {
  name = "${var.name_prefix}-launch-template"

  update_default_version = true

  image_id      = var.ami_id
  instance_type = var.instance_type

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.wordpress.id]
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.instance_profile.name
  }

  key_name = aws_key_pair.deployer.key_name

  user_data = base64encode(local.user_data)

  tags = {
    Name = "${var.name_prefix}-launch-template"
  }
}

resource "aws_instance" "this" {
  lifecycle {
    replace_triggered_by = [terraform_data.user_data_replace]
    ignore_changes       = [user_data]
  }

  iam_instance_profile = aws_iam_instance_profile.instance_profile.name

  launch_template {
    id = aws_launch_template.this.id
  }

  tags = {
    Name = "${var.name_prefix}"
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
    cidr_blocks = ["${var.ingress_source_cidr}"]
  }



  ingress {
    description = "HTTP"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${var.ingress_source_cidr}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
