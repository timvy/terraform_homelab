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
    bucket = "tofu-backend"
    # Semaphore puts the state file in environment subfolders /env:/docker
    key                         = "env:/docker/terraform.tfstate"
    # key                         = "terraform.tfstate"
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

data "bitwarden_secret" "pihole" {
  key = "pihole"
}

data "bitwarden_secret" "domain_home" {
  key = "domain_home"
}
data "bitwarden_secret" "domain_tailscale" {
  key = "domain_tailscale"
}
data "bitwarden_secret" "domain_pg" {
  key = "domain_pg"
}

locals {
  domain_home      = data.bitwarden_secret.domain_home.value
  domain_pg        = data.bitwarden_secret.domain_pg.value
  domain_tailscale = data.bitwarden_secret.domain_tailscale.value
}

provider "pihole" {
  url      = "http://lxc-pihole2.${local.domain_tailscale}"
  password = data.bitwarden_secret.pihole.value
}

# Dynamic Docker providers using OpenTofu's for_each feature
provider "docker" {
  alias    = "hosts"
  for_each = local.docker_hosts
  host     = each.value.host
  ssh_opts = each.value.ssh_opts
}

data "bitwarden_secret" "tailscale_api_key" {
  key = "tailscale_api_key"
}

provider "tailscale" {
}
