data "bitwarden_item_login" "tailscale_tsdproxy" {
  search = "tailscale_tsdproxy_key"
}

locals {
  tsdproxy_config = yamlencode({
    docker = {
      local = {
        host                     = "unix:///var/run/docker.sock"
        targetHostname           = "host.docker.internal"
        tryDockerInternalNetwork = false
      }
    }
    lists = {
      for k, v in local.tsdproxy_lists : k => {
        filename              = "/config/${k}.yaml"
        defaultProxyProvider  = "default"
        defaultProxyAccessLog = true
      }
    }
    tailscale = {
      providers = {
        default = {
          authKey     = data.bitwarden_item_login.tailscale_tsdproxy.password
          authKeyFile = ""
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
      json  = true
    }
    proxyAccessLog = true
  })
  tsdproxy_lists = {
    containers = yamlencode({
      for cname, port in local.tsdproxy_containers : cname => {
        ports = {
          "443/https" = {
            targets = [
              "http://${cname}:${port}"
            ]
          }
          "80/http" = {
            targets = [
              "http://${cname}:${port}"
            ]
          }
        }
      }
      }
    )
  }
  tsdproxy_containers = {
    "files"       = "80"
    "giftmanager" = "5000"
    "ittools"     = "80"
    "kuma"        = "3001"
    "pinchflat"   = "4008"
    "portainer"   = "9000"
    "search"      = "8080"
    "wallabag"    = "80"
    "yrouter"     = "8787"
  }
}
