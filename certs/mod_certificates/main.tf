resource "acme_registration" "this" {
  email_address   = var.email_address
}

data "bitwarden_secret" "hetzner_dns_api" {
  key = "hetzner_dns_api"
}

resource "acme_certificate" "this" {
  account_key_pem       = acme_registration.this.account_key_pem
  common_name           = var.common_name
  recursive_nameservers = ["8.8.8.8:53"]

  dns_challenge {
    provider = "hetzner"

    config = {
      HETZNER_API_KEY = data.bitwarden_secret.hetzner_dns_api.value
    }
  }
}

data "bitwarden_project" "homelab" {
  id = "8e37b6b5-0614-453e-bce3-b2f5009aec66"
}

resource "bitwarden_secret" "certificate" {
  key = "certificate_${var.common_name}_certificate"
  value = acme_certificate.this.certificate_pem
  project_id = data.bitwarden_project.homelab.id
  note = "Certificate for ${var.common_name}"
}

resource "bitwarden_secret" "privkey" {
  key = "certificate_${var.common_name}_privkey"
  value = acme_certificate.this.private_key_pem
  project_id = data.bitwarden_project.homelab.id
  note = "Private key for ${var.common_name}"
}

resource "bitwarden_secret" "fullchain" {
  key = "certificate_${var.common_name}_fullchain"
  value = acme_certificate.this.private_key_pem
  project_id = "${acme_certificate.this.certificate_pem}${acme_certificate.this.issuer_pem}"
  note = "Full chain for ${var.common_name}"
}
