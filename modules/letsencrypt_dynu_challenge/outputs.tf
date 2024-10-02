output "private_pem" {
  description = "Private Certificate in PEM format"
  value       = acme_certificate.certificate.private_key_pem
}

output "public_pem" {
  description = "Public Certificate in PEM format"
  value       = acme_certificate.certificate.certificate_pem
}

output "issuer_pem" {
  description = "Public Certificate in PEM format"
  value       = acme_certificate.certificate.issuer_pem
}