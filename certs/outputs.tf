output "all_certificates" {
  value = {
    for domain, cert_module in module.certificates :
    domain => {
      fullchain = cert_module.certificate_chain
      privkey   = cert_module.certificate_key
      certificate  = cert_module.certificate_cert
    }
  }
  sensitive = true
}
