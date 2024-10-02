variable "name_prefix" {
  type    = string
  default = "my-instance"
}

variable "instance_class" {
    type = string
    default = "db.t3.micro"
}

variable "allocated_storage" {
  type = number
  default = 20
}

variable "engine" {
    type = string
    default = "mariadb"
}

variable "engine_version" {
    type = string
    default = "10.6"
}

variable "db_port" {
    type = number
    default = 3306
}

variable "db_protocol" {
    type = string
    default = "tcp"
}

variable "db_name" {
    type = string
    default = "wordpress"
}
