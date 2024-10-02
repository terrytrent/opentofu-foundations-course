variable "name_prefix" {
  type    = string
  default = "my-instance"
}

variable "ami_id" {
  type    = string
  default = "ami-0ebfd941bbafe70c6"
}

variable "instance_type" {
    type = string
    default = "t2.micro"
}

variable "db_host" {
    type = string
    default = ""
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

variable "private_pem" {
    type = string
}
variable "public_pem" {
    type = string
}
variable "issuer_pem" {
    type = string
}

variable "docker_compose_download_url" {
  type = string
  default = ""
}

variable "ingress_source_cidr" {
  type = string
}