module "aws_instance" {
  source = "./modules/aws_instance"

  name_prefix   = "week2-instance"
  ami           = "ami-0ff8a91507f77f867"
  instance_type = "t2.micro"
  user_data_base64 = base64encode(templatefile(
    "user_data.tftpl",
    {
      "DB_HOST"    = "${module.aws_db_instance.endpoint}"
      "IMAGE_NAME" = "${var.image.name}"
      "IMAGE_TAG"  = "${var.image.tag}"
    }
    )
  )
  tags = {
    Name = "Terry"
  }
}

module "aws_db_instance" {
  source            = "./modules/aws_db_instance"
  name_prefix       = "week2-instance"
  instance_class    = "db.t3.micro"
  allocated_storage = 20
  engine            = "mariadb"
  engine_version    = "10.6"
  db_name           = "wordpress"

  tags = {
    Name = "Terry"
  }
}