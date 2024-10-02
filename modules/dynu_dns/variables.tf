variable "dns_domain" {
  type    = string
  default = ""

  validation {
    condition = length(var.dns_domain) > 0
    error_message = "DNS Domain must be provided"
  }
}

variable "dns_subdomain" {
  type    = string
  default = ""

  validation {
    condition = length(var.dns_subdomain) > 0
    error_message = "DNS Subdomain must be provided"
  }
}

variable "dynu_api_key" {
  type = string
  default = ""

  validation {
    condition = length(var.dynu_api_key) > 0
    error_message = "Dynu API Key must be provided"
  }
}

variable "dns_ipv4_address" {
  type = string
  default = ""

  validation {
    condition = can(cidrnetmask(join("/", [var.dns_ipv4_address, "32"])))
    error_message = "The IPv4 Address is not valid"
  }
}