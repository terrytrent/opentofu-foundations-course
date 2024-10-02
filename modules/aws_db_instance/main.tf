data "aws_vpc" "default" {
  filter {
    name   = "isDefault"
    values = ["true"]
  }
}

resource "random_id" "security_group_mariadb" {
  byte_length = 8
}

resource "random_pet" "wordpress_db_user" {
  keepers = {
    # Generate a new pet name each time we switch to a new AMI id
    name_prefix = var.name_prefix
  }
  separator = ""
}

resource "random_password" "wordpress_db_password" {
  keepers = {
    # Generate a new pet name each time we switch to a new AMI id
    name_prefix = var.name_prefix
  }
  length      = 16
  special     = false
  min_lower   = 4
  min_numeric = 4
  min_upper   = 4
}

resource "aws_ssm_parameter" "db_credentials" {
  name  = "db_credentials"
  type  = "SecureString"
  value = jsonencode({ username = "${random_pet.wordpress_db_user.id}", password = "${random_password.wordpress_db_password.result}" })

  lifecycle {
    ignore_changes = [
      value
    ]
  }
}

resource "aws_db_instance" "this" {
  identifier        = "${var.name_prefix}-${var.db_name}"
  instance_class    = var.instance_class
  allocated_storage = var.allocated_storage
  engine            = var.engine
  engine_version    = var.engine_version

  db_name  = var.db_name
  username = random_pet.wordpress_db_user.id
  password = random_password.wordpress_db_password.result

  vpc_security_group_ids = [aws_security_group.database.id]
  skip_final_snapshot    = true

  tags = {
    Name = "${var.name_prefix}"
  }
}

resource "aws_security_group" "database" {
  name        = "${var.name_prefix}-${var.engine}-${random_id.security_group_mariadb.hex}"
  description = "Allow access to ${var.engine}"

  lifecycle {
    create_before_destroy = true
  }

  ingress {
    from_port = var.db_port
    to_port   = var.db_port
    protocol  = var.db_protocol

    cidr_blocks = concat([data.aws_vpc.default.cidr_block])
  }
}
