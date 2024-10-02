locals {
    subject_alternative_names = concat([var.common_name],var.subject_alt_names)
}

resource "acme_registration" "reg" {
  email_address = var.letsencrypt_email_reg
}

resource "acme_certificate" "certificate" {
  depends_on                = [acme_registration.reg]
  account_key_pem           = acme_registration.reg.account_key_pem
  common_name               = var.common_name
  subject_alternative_names = local.subject_alternative_names

  dns_challenge {
    provider = "dynu"
    config = {
      DYNU_API_KEY = var.dynu_api_key
    }
  }
}

resource "aws_ssm_parameter" "letsencrypt_certificate_private" {
  name       = "letsencrypt_certificate_private"
  type       = "SecureString"
  value      = jsonencode({ private_pem = "${acme_certificate.certificate.private_key_pem}" })

  lifecycle {
    ignore_changes = [
      value
    ]
  }
}

resource "aws_ssm_parameter" "letsencrypt_certificate_public" {
  depends_on = [acme_certificate.certificate]
  name       = "letsencrypt_certificate_public"
  type       = "String"
  value      = jsonencode({ public_pem = "${acme_certificate.certificate.certificate_pem}" })

  lifecycle {
    ignore_changes = [
      value
    ]
  }
}

resource "aws_ssm_parameter" "letsencrypt_certificate_issuer" {
  depends_on = [acme_certificate.certificate]
  name       = "letsencrypt_certificate_issuer"
  type       = "String"
  value      = jsonencode({ issuer_pem = "${acme_certificate.certificate.issuer_pem}" })

  lifecycle {
    ignore_changes = [
      value
    ]
  }
}
