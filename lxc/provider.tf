terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.1-rc9"
    }
    zfs = {
      source = "MathiasPius/zfs"
    }
    bitwarden = {
      source = "maxlaverse/bitwarden"
    }
    splunk = {
      source = "splunk/splunk"
    }
    tailscale = {
      source = "tailscale/tailscale"
    }
  }
  backend "s3" {
    bucket                      = "tofu-backend"
    key                         = "terraform.tfstate"
    region                      = "main" # this is required, but will be skipped!
    skip_credentials_validation = true   # this will skip AWS related validation
    skip_metadata_api_check     = true
    skip_region_validation      = true
  }
}

provider "bitwarden" {
  experimental {
    embedded_client = true
  }
}

data "bitwarden_secret" "domain_home" {
  key = "domain_home"
}
data "bitwarden_secret" "domain_tailscale" {
  key = "domain_tailscale"
}

locals {
  domain_home      = data.bitwarden_secret.domain_home.value
  domain_tailscale = data.bitwarden_secret.domain_tailscale.value
}

provider "proxmox" {}

provider "zfs" {
  user     = "ansible"
  host     = "pve-hpe.${local.domain_tailscale}"
  key  = "/config/semaphore/.ssh/semaphore_homelab.key"
}

provider "splunk" {}

provider "tailscale" {}
