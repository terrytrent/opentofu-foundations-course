output "instance_arn" {
  description = "AWS EC2 Instance ARN"
  value       = aws_instance.this.arn
}

output "instance_ssm_command" {
  description = "AWS SSM command to connect to instance"
  value       = "aws ssm start-session --target ${aws_instance.this.id}"
}

output "instance_url" {
  description = "Public HTTP URL of the instance"
  value       = "http://${aws_instance.this.public_ip}"
}

output "rds_endpoint" {
  description = "MariaDB RDS Endpoint"
  value       = aws_db_instance.this.endpoint
}