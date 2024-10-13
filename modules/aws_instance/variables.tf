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

variable "ingress_source_cidr" {
  type = string
}

variable "wordpress_security_group_ingress_rules" {
  type = list(object({
    description = string
    from_port = number
    to_port = number
    protocol = string
    cidr_blocks = optional(string)
  }))
  default = [{
    description = "HTTP"
    from_port = 80
    to_port = 80
    protocol = "tcp"
  },
  {
    description = "HTTPS"
    from_port = 443
    to_port = 443
    protocol = "tcp"
  }]
}

variable "wordpress_security_group_egress_rules" {
  type = list(object({
    description = string
    from_port = number
    to_port = number
    protocol = string
    cidr_blocks = optional(list(string))
  }))
  default = [{
    description = "Outbound to anywhere"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }]
}