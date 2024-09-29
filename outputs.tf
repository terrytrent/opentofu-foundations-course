output "instance_arn" {
  description = "AWS EC2 Instance ARN"
  value       = aws_instance.this.arn
}

output "instance_ip" {
  description = "Public IP of the instance"
  value       = aws_instance.this.public_ip
}

output "instance_ssh_command" {
  description = "SSH command to connect to instance"
  value       = "ssh -i ~/.ssh/deployer.id_rsa ec2-user@${aws_instance.this.public_ip}"
}

output "instance_url" {
  description = "Public HTTP URL of the instance"
  value       = "http://${aws_instance.this.public_ip}"
}

output "rds_endpoint" {
  description = "MariaDB RDS Endpoint"
  value       = aws_db_instance.this.endpoint
}

output "rsa_public_key" {
  value = trimspace(tls_private_key.rsa.public_key_openssh)
}