locals {

  traefik_static_config = yamlencode({
    log : {
      format = "json"
    }
    accessLog = {
      format = "json"
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
        http = {
          tls = {
            certResolver = "letsencrypt"
            domains = [
              {
                main = "*.${local.domain_home}"
                sans = [local.domain_home]
              }
            ]
          }
        }
      }
    }
    certificatesResolvers = {
      letsencrypt = {
        acme = {
          dnsChallenge = {
            provider  = "hetzner"
            resolvers = ["1.1.1.1:53", "8.8.8.8:53"]
          }
          email    = "info@${local.domain_home}"
          storage  = "/letsencrypt/acme.json"
          caServer = "https://acme-v02.api.letsencrypt.org/directory"
        }
      }
    }
  })

  traefik_dynamic_config = yamlencode({
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
            users = ["admin:{PLAIN}${random_password.this["lxc-docker3.traefik_admin_user"].result}"]
          }
        }
      }
    }
  })
}
