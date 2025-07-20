terraform {
  required_providers {
    bitwarden = {
      source = "maxlaverse/bitwarden"
    }
    acme = {
      source = "vancluever/acme"
    }
  }
  backend "s3" {
    bucket = "tofu-backend"
    key                         = "terraform.tfstate"
    key                         = "homelab/certs/terraform.tfstate"
    region                      = "main" # this is required, but will be skipped!
    skip_credentials_validation = true   # this will skip AWS related validation
    skip_metadata_api_check     = true
    skip_region_validation      = true
  }  
}

provider "acme" {
  server_url = "https://acme-v02.api.letsencrypt.org/directory"
}

provider "bitwarden" {}

locals {
  domain_home = data.bitwarden_secret.secret["domain_home"].value
}
