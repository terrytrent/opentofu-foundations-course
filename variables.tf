variable "name_prefix" {
  type    = string
  default = "my-instance"
}

variable "ami_id" {
  type = string
  default = "ami-0ebfd941bbafe70c6"
}

variable "image" {
  type = object({
    name = string
    tag  = string
  })

  description = "Docker image to run in the EC2 instance."
  default = {
    name = "nginx"
    tag  = "latest"
  }
}

variable "enable_public_mariadb_access" {
  description = "A list of CIDR blocks to permit public MariaDB access. Set to your IP CIDR block to enable (https://www.whatismyip.com/)"
  type        = list(string)
  default     = []
}

variable "ssh_key_path" {
  type    = string
  default = "~/.ssh/"
}

variable "deployer_rsa_key_name" {
  type    = string
  default = "deployer"
}