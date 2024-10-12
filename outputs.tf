output "instance_ssm_command" {
  description = "AWS SSM command to connect to instance"
  value       = "aws ssm start-session --target ${module.aws_instance.instance_id}"
}

output "instance_url" {
  description = "Public HTTP URL of the instance"
  value       = "http://${local.common_name}"
}