variable name_prefix {
    type = string
    default = "week2-instance"
}

variable ami_id {
    type = string
    default = "ami-0ff8a91507f77f867"
}

variable ec2_instance_type {
    type = string
    default = "t2.micro"
}

variable image {
    type = map(string)
    default = {
        name = "wordpress"
        tag = "latest"
    }
}

variable db_instance_class {
    type = string
    default = "db.t3.micro"
}

variable "letsencrypt_email_reg" {
    type = string
    default = "toadatmushroomkingdom@gmail.com"
}

variable dns_domain {
    type = string
    default = "trentathome.xyz"
}

variable "dns_subdomain" {
  type = string
  default = "opentofu"
}

variable "subject_alt_names" {
    type = list
    default = []
}