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
    aws_db_instance.this,
    aws_iam_instance_profile.instance_profile,
    aws_security_group.wordpress,
    aws_security_group.ssh,
    aws_key_pair.deployer,
    random_pet.wordpress_db_user
  ]
  ami           = "ami-0ff8a91507f77f867"
  instance_type = "t2.micro"

  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.wordpress.id, aws_security_group.ssh.id]

  key_name = aws_key_pair.deployer.key_name

  iam_instance_profile = aws_iam_instance_profile.instance_profile.name

  user_data_replace_on_change = true
  user_data_base64 = base64encode(templatefile(
    "user_data.tftpl",
    {
      "DB_HOST"    = "${aws_db_instance.this.endpoint}"
      "IMAGE_NAME" = "${var.image.name}"
      "IMAGE_TAG"  = "${var.image.tag}"
    }
    )
  )

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