locals {
  docker_compose_download_url = [for a in jsondecode(data.http.docker_compose_release_json.response_body)["assets"] : a
  if a["name"] == "docker-compose-linux-x86_64"][0]["browser_download_url"]

  common_name = "${var.dns_subdomain}.${var.dns_domain}"
}

data "http" "docker_compose_release_json" {
  url    = "https://api.github.com/repos/docker/compose/releases/latest"
  method = "GET"
}

data "aws_ssm_parameter" "dynu_api_key" {
  name = "dynu_api_key"
}

data "http" "myip" {
  url = "https://ipv4.icanhazip.com"
}

module letsencrypt_certificate {
  source = "./modules/letsencrypt_dynu_challenge"

  letsencrypt_email_reg = var.letsencrypt_email_reg
  common_name = local.common_name
  subject_alt_names = var.subject_alt_names
  dynu_api_key = data.aws_ssm_parameter.dynu_api_key.value
}

module "aws_db_instance" {
  source            = "./modules/aws_db_instance"

  name_prefix       = var.name_prefix
  instance_class    = var.db_instance_class
  allocated_storage = 20
  engine            = "mariadb"
  engine_version    = "10.6"
  db_name           = "wordpress"
}

module "aws_instance" {
  source = "./modules/aws_instance"

  name_prefix   = var.name_prefix
  ami_id           = var.ami_id
  instance_type = var.ec2_instance_type
  db_host = module.aws_db_instance.db_endpoint
  image = {
    name = "wordpress"
    tag = "latest"
  }

  private_pem = module.letsencrypt_certificate.private_pem
  public_pem = module.letsencrypt_certificate.public_pem
  issuer_pem = module.letsencrypt_certificate.issuer_pem

  docker_compose_download_url = local.docker_compose_download_url

  ingress_source_cidr = "${chomp(data.http.myip.response_body)}/32"
}

module dynu_dns {
  source = "./modules/dynu_dns"

  dns_domain = var.dns_domain
  dns_subdomain = var.dns_subdomain
  dynu_api_key = data.aws_ssm_parameter.dynu_api_key.value
  dns_ipv4_address = module.aws_instance.instance_ip
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