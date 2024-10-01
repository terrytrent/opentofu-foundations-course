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
  input = filesha1("user_data.tftpl")
}

resource "aws_launch_template" "this" {
  depends_on = [
    aws_ssm_parameter.letsencrypt_certificate_private,
    aws_ssm_parameter.letsencrypt_certificate_public,
    aws_ssm_parameter.letsencrypt_certificate_issuer,
    aws_db_instance.this,
    aws_security_group.wordpress,
    aws_key_pair.deployer,
    random_pet.wordpress_db_user
  ]
  name = "${random_pet.wordpress_db_user.keepers.name_prefix}-launch-template"

  image_id      = var.ami_id
  instance_type = "t2.micro"

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.wordpress.id]
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.instance_profile.name
  }

  key_name = aws_key_pair.deployer.key_name

  user_data = base64encode(templatefile(
    "user_data.tftpl",
    {
      "DB_HOST"    = "${aws_db_instance.this.endpoint}"
      "IMAGE_NAME" = "${var.image.name}"
      "IMAGE_TAG"  = "${var.image.tag}"
    }
    )
  )

  tags = {
    Name = "${random_pet.wordpress_db_user.keepers.name_prefix}-launch-template"
  }
}

resource "aws_instance" "this" {
  depends_on = [
    aws_launch_template.this,
    terraform_data.user_data_replace
  ]

  lifecycle {
    replace_triggered_by = [terraform_data.user_data_replace]
    ignore_changes       = [user_data]
  }

  iam_instance_profile = aws_iam_instance_profile.instance_profile.name

  launch_template {
    id = aws_launch_template.this.id
  }

  tags = {
    Name = "${random_pet.wordpress_db_user.keepers.name_prefix}"
  }
}

resource "aws_db_instance" "this" {
  identifier        = "${var.name_prefix}-wordpress"
  instance_class    = "db.t3.micro"
  allocated_storage = 20
  engine            = "mariadb"
  engine_version    = "10.6"

  db_name  = "wordpress"
  username = random_pet.wordpress_db_user.id
  password = random_password.wordpress_db_password.result

  vpc_security_group_ids = [aws_security_group.mariadb.id]
  skip_final_snapshot    = true

  tags = {
    Name = "${random_pet.wordpress_db_user.keepers.name_prefix}"
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

resource "aws_security_group" "mariadb" {
  name        = "${var.name_prefix}-mariadb-${random_id.security_group_mariadb.hex}"
  description = "Allow access to MariaDB"

  lifecycle {
    create_before_destroy = true
  }

  ingress {
    from_port = 3306
    to_port   = 3306
    protocol  = "tcp"

    cidr_blocks = concat([data.aws_vpc.default.cidr_block])
  }
}