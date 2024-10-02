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