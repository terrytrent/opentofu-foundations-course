variable "letsencrypt_email_reg" {
  type = string
  default = ""

    validation {
        condition = length(var.letsencrypt_email_reg) > 0
        error_message = "Common name must be provided"
    }
}

variable "common_name" {
    type = string
    default = ""

    validation {
        condition = length(var.common_name) > 0
        error_message = "Common name must be provided"
    }
}

variable "subject_alt_names" {
    type = list(string)
    default = []
}

variable "dynu_api_key" {
  type = string
  default = ""

  validation {
    condition = length(var.dynu_api_key) > 0
    error_message = "Dynu API Key must be provided"
  }
}