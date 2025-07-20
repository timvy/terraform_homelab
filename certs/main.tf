data "bitwarden_secret" "domain_home" {
  key = "domain_home"
}

locals {
  domain_home = data.bitwarden_secret.secret["domain_home"].value
  domains = {
    home = {
      common_name = "*.${local.domain_home}"
    }
    nextcloud = {
      common_name = "nextcloud.${local.domain_home}"
    }
  }
}

data "bitwarden_secret" "letsencrypt_email" {
  key = "letsencrypt_email"
}

module "certificates" {
  source = "./mod_certificates"

  for_each = local.domains

  name        = each.key
  common_name = each.value.common_name
  email_address = data.bitwarden_secret.secret["letsencrypt_email"].value
}
