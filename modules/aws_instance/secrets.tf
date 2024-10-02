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

resource "random_id" "security_group_wordpress" {
  byte_length = 8
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = trimspace(tls_private_key.rsa.public_key_openssh)
}

resource "aws_ssm_parameter" "deployer_ssh_key" {
  name      = "deployer_ssh_key"
  type      = "SecureString"
  overwrite = true
  value     = jsonencode({ private = "${tls_private_key.rsa.private_key_pem}", public = "${tls_private_key.rsa.public_key_openssh}" })
}