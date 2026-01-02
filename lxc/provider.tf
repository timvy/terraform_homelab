terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.2-rc07"
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
  command_prefix = "sudo"
  user           = "ansible"
  host           = "pve-hpe.${local.domain_tailscale}"
  # key      = "semaphore_homelab.key"
  key_path = "/config/semaphore/.ssh/semaphore_homelab.key"
}

provider "splunk" {
  insecure_skip_verify = true
}

provider "tailscale" {}
