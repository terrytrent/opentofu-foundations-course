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

resource "aws_ssm_parameter" "wordpress_admin_credentials" {
  name      = "wordpress_admin_credentials"
  type      = "SecureString"
  overwrite = true
  value     = jsonencode({ username = "${random_pet.wordpress_admin.id}", password = "${random_password.wordpress_admin_password.result}" })
}