data "bitwarden_item_login" "tailscale_tsdproxy" {
  search = "tailscale_tsdproxy_key"
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
          authKey = data.bitwarden_item_login.tailscale_tsdproxy.password
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
