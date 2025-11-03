locals {

  traefik_static_config = yamlencode({
    accessLog = {
      enabled = true
    }
    providers = {
      file = {
        directory = "/etc/traefik/dynamic"
      }
      docker = {}
    }
    entryPoints = {
      http = {
        address = ":80"
      }
      https = {
        address = ":443"
      }
    }
  })

  traefik_dynamic_config = yamlencode({
    tls = {
      certificates = [
        {
          certFile = "/etc/traefik/ssl/home.fullchain.pem"
          keyFile  = "/etc/traefik/ssl/home.privkey.pem"
        },
        {
          certFile = "/etc/traefik/ssl/ts.fullchain.pem"
          keyFile  = "/etc/traefik/ssl/ts.privkey.pem"
        }
      ]
    }
    http = {
      routers = {
        nextcloud = {
          entryPoints = ["https"]
          tls         = {}
          service     = "nextcloud"
          rule        = "Host(`cloud.internal`)"
        }
        api = {
          rule        = "Host(`traefik.${local.domain_home}`) && (PathPrefix(`/api`) || PathPrefix(`/dashboard`))"
          service     = "api@internal"
          middlewares = ["admin-auth"]
        }
      }
      services = {
        nextcloud = {
          loadBalancer = {
            servers = [
              {
                url = "http://192.168.6.17"
              }
            ]
          }
        }
      }
      middlewares = {
        admin-auth = {
          basicAuth = {
            users = ["admin:{PLAIN}${random_password.this["traefik_admin_user"].result}"]
          }
        }
      }
    }
  })
}
