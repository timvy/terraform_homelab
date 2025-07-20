output "certificate_chain" {
  value = "${acme_certificate.this.certificate_pem}${acme_certificate.this.issuer_pem}"
  sensitive   = true
}

output "certificate_key" {
  value = acme_certificate.this.private_key_pem
  sensitive   = true
}

output "certificate_cert" {
  value = acme_certificate.this.certificate_pem
  sensitive   = true
}
