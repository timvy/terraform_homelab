terraform {
  required_providers {
    bitwarden = {
      source = "maxlaverse/bitwarden"
    }
    zfs = {
      source  = "MathiasPius/zfs"
      version = "=0.4.0"
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
    dns = {}
    tailscale = {
      source = "tailscale/tailscale"
    }
  }
}

data "dns_a_record_set" "docker_host" {
  host = "lxc-docker3.internal"
}

locals {
  web_host_ip = join(",", data.dns_a_record_set.docker_host.addrs)
}
