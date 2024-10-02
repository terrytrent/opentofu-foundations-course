variable "name_prefix" {
  type = string
}

variable "description" {
  type        = string
  description = "Set infrastructure description"
  default     = "OpenTofu Week 2 infrastructure description"
}

variable "ami" {
  type        = string
  description = "EC2 AMI"
  // Amazon Linux 2
  default = "ami-0ff8a91507f77f867"

  validation {
    condition = length(regex("^ami-[0-9a-z]{17}$", var.ami)) > 0
    error_message = "Not a valid AMI"
  }
}

variable "instance_type" {
  type        = string
  description = "SKU for EC2"
  default     = "t2.micro"

  validation {
    condition = contains(["t2.micro", "t3.micro"], var.instance_type)
    error_message = "Invalid instance type, must be \"t2.micro\" or \"t3.micro\""
  }
}

variable "user_data_base64" {
  type        = string
  description = "Launch script for EC2"
  default     = ""
}

variable "tags" {
  type        = map(string)
  description = "Set your infrastructure tags"
  default     = {}
}

variable "ssh_key_path" {
  type    = string
  default = "~/.ssh/"
}

variable "deployer_rsa_key_name" {
  type    = string
  default = "deployer"
}
