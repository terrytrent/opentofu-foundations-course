data "aws_vpc" "default" {
  filter {
    name   = "isDefault"
    values = ["true"]
  }
}

resource "aws_db_instance" "this" {
  identifier        = "${var.name_prefix}-wordpress"
  instance_class    = "${var.instance_class}"
  allocated_storage = "${var.allocated_storage}"
  engine            = "${var.engine}"
  engine_version    = "${var.engine_version}"

  db_name  = "${var.db_name}"
  username = random_pet.wordpress_db_user.id
  password = random_password.wordpress_db_password.result

  vpc_security_group_ids = [aws_security_group.mariadb.id]
  skip_final_snapshot    = true

  tags = var.tags
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