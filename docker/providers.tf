terraform {
  required_providers {
    bitwarden = {
      source = "maxlaverse/bitwarden"
    }
    docker = {
      source = "kreuzwerker/docker"
    }
    random = {
      version = "~> 3.0"
    }
    pihole = {
      source = "iolave/pihole"
    }
    tailscale = {
      source = "tailscale/tailscale"
    }
  }
  backend "s3" {
    bucket                      = "tofu-backend"
    key                         = "homelab/docker/terraform.tfstate"
    region                      = "main" # this is required, but will be skipped!
    skip_credentials_validation = true   # this will skip AWS related validation
    skip_metadata_api_check     = true
    skip_region_validation      = true
  }
}

provider "random" {}

provider "bitwarden" {
  experimental {
    embedded_client = true
  }
}

data "bitwarden_item_login" "pihole" {
  search = "pihole"
}

data "bitwarden_item_secure_note" "domains" {
  search = "domains"
}

locals {
  domain_home      = try([for field in data.bitwarden_item_secure_note.domains.field : field.text if field.name == "home"][0], null)
  domain_tailscale = try([for field in data.bitwarden_item_secure_note.domains.field : field.text if field.name == "tailscale"][0], null)
}

provider "pihole" {
  url      = "http://lxc-pihole2.${local.domain_tailscale}"
  password = data.bitwarden_item_login.pihole.password
}

provider "docker" {
  alias    = "lxc-docker3"
  host     = "ssh://root@lxc-docker3.internal:22"
  ssh_opts = ["-o", "ControlMaster=auto", "-o", "ControlPath=~/.ssh/control-%C", "-o", "ControlPersist=yes"]
}

data "bitwarden_item_login" "tailscale_api_key" {
  search = "tailscale_api_key"
}

provider "tailscale" {
  api_key = data.bitwarden_item_login.tailscale_api_key.password
  tailnet = "timvy.github"
}
