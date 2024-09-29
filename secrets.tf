resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_sensitive_file" "rsa_private" {
  content         = tls_private_key.rsa.private_key_pem
  filename        = "${var.ssh_key_path}${var.deployer_rsa_key_name}.id_rsa"
  file_permission = 0600
}

resource "local_file" "rsa_public" {
  content         = trimspace(tls_private_key.rsa.public_key_openssh)
  filename        = "${var.ssh_key_path}${var.deployer_rsa_key_name}.id_rsa.pub"
  file_permission = 0644
}

resource "random_id" "security_group_mariadb" {
  byte_length = 8
}

resource "random_id" "security_group_wordpress" {
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

resource "random_pet" "wordpress_admin" {
  separator = ""
}

resource "random_password" "wordpress_admin_password" {
  length      = 20
  special     = true
  min_lower   = 4
  min_numeric = 4
  min_upper   = 4
  min_special = 4
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

resource "aws_ssm_parameter" "wordpress_admin_credentials" {
  name  = "wordpress_admin_credentials"
  type  = "SecureString"
  value = jsonencode({ username = "${random_pet.wordpress_admin.id}", password = "${random_password.wordpress_admin_password.result}" })

  lifecycle {
    ignore_changes = [
      value
    ]
  }
}