locals {
  domains = {
    home = {
      common_name = "*.${local.domain_home}"
    }
    nextcloud = {
      common_name = "nextcloud.${local.domain_home}"
    }
  }
}

data "bitwarden_item_secure_note" "letsencrypt" {
  search = "certbot_letsencrypt"
}

module "certificates" {
  source = "./mod_certificates"

  for_each = local.domains

  name        = each.key
  common_name = each.value.common_name
  email_address = data.bitwarden_secret.secret["letsencrypt_email"].value
}
