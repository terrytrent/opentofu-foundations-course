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
  name      = "db_credentials"
  type      = "SecureString"
  overwrite = true
  value     = jsonencode({ username = "${random_pet.wordpress_db_user.id}", password = "${random_password.wordpress_db_password.result}" })
}