terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
    }
    zfs = {
      source  = "MathiasPius/zfs"
      version = "=0.4.0"
    }
    bitwarden = {
      source = "maxlaverse/bitwarden"
    }
    random = {
      version = "~> 3.0"
    }
    splunk = {
      source = "splunk/splunk"
    }
    tailscale = {
      source = "tailscale/tailscale"
    }       
  }
}
