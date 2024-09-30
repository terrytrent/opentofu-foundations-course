terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.68"
    }
    local = {
      source = "hashicorp/local"
    }
    random = {
      source = "hashicorp/random"
    }
    tls = {
      source = "hashicorp/tls"
    }
    http = {
      source = "hashicorp/http"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      environment = "dev"
      project     = "opentofu-foundations"
    }
  }
}

provider "local" {}
provider "random" {}
provider "tls" {}
provider "http" {}