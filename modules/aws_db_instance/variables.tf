variable "name_prefix" {
  type    = string
  default = "my-instance"
}

variable "enable_public_mariadb_access" {
  description = "A list of CIDR blocks to permit public MariaDB access. Set to your IP CIDR block to enable (https://www.whatismyip.com/)"
  type        = list(string)
  default     = []
}

variable "instance_class" {
  description = "Instance class for the DB instance"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Allocated storage in GB"
  type        = number
  default     = 20
}

variable "engine" {
  description = "Database engine"
  type        = string
  default     = "mariadb"
}

variable "engine_version" {
  description = "Database engine version"
  type        = string
  default     = "10.6"
}

variable "db_name" {
  description = "Name of the database"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the database instance"
  type        = map(string)
  default     = {}
}