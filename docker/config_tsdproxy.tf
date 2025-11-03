data "bitwarden_secret" "tailscale_tsdproxy_clientid" {
  key = "tailscale_tsdproxy_clientid"
}

data "bitwarden_secret" "tailscale_tsdproxy_clientsecret" {
  key = "tailscale_tsdproxy_clientsecret"
}

locals {
  tsdproxy_config = yamlencode({
    docker = {
      local = {
        host                      = "unix:///var/run/docker.sock"
        targetHostname            = "172.31.0.1"
        tryDockerInternalNetwork = false
      }
    }
    lists = {}
    tailscale = {
      providers = {
        default = {
          clientId     = data.bitwarden_secret.tailscale_tsdproxy_clientid.value
          clientSecret = data.bitwarden_secret.tailscale_tsdproxy_clientsecret.value
        }
      }
      dataDir = "/data/"
    }
    http = {
      hostname = "0.0.0.0"
      port     = 8080
    }
    log = {
      level = "info"
      json  = false
    }
    proxyAccessLog = true
  })
}
