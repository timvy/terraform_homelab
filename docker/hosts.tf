# Docker hosts configuration
# Define all Docker hosts and their configurations here

locals {
  # Define all Docker hosts
  docker_hosts = {
    lxc-docker3 = {
      host     = "ssh://ansible@lxc-docker3.${local.domain_tailscale}:22"
      ssh_opts = ["-o", "ControlMaster=auto", "-o", "ControlPath=~/.ssh/control-%C", "-o", "ControlPersist=yes", "-o", "StrictHostKeyChecking=no", "-o", "IdentityFile=~/.ssh/semaphore_homelab.key"]

      # Networks for this host
      networks = {
        healthchecks = {}
        download     = {}
        jellyfin     = {}
        kuma         = {}
        samba        = {}
        tsdproxy     = {}
        searxng      = {}
        firefly      = {}
        wallabag     = {}
        traefik      = {}
        portainer    = {}
        web          = {}
      }

      # Secrets for this host
      secrets = {
        firefly_db_root_pwd = {}
        firefly_db_pwd      = {}
        firefly_app_key     = {}
        wallabag_env_secret = {}
        samba_user_tim = {
          length = 32
        }
        samba_user_hassio = {
          length = 32
        }
        traefik_admin_user = {}
      }

      # Containers for this host
      containers = {
        healthchecks = {
          image   = "lscr.io/linuxserver/healthchecks:latest"
          network = ["healthchecks"]
          env     = local.env_healthchecks
          volumes = {
            healthchecks = {
              container_path = "/config"
            }
          }
          lsio_mods_tailscale_enabled = true
          lsio_mods_tailscale_vars = {
            tailscale_serve_port = 8000
            tailscale_hostname   = "hc"
          }
        }
        radarr = {
          image   = "lscr.io/linuxserver/radarr:latest"
          network = ["download"]
          env = [
            "TZ=Europe/Brussels",
            "PUID=1000",
            "PGID=1000",
          ]
          mounts = {
            radarr_config = {
              source = "/mnt/bindmounts/radarr_config"
              target = "/config"
            }
            radarr_movies = {
              source = "/media/videos/hdmovies"
              target = "/movies"
            }
            radarr_downloads = {
              source = "/media/downloads"
              target = "/downloads"
            }
          }
          lsio_mods_tailscale_enabled = true
          lsio_mods_tailscale_vars = {
            tailscale_serve_port = 7878
          }
        }
        prowlarr = {
          image   = "lscr.io/linuxserver/prowlarr:latest"
          network = ["download"]
          env = [
            "TZ=Europe/Brussels",
            "PUID=1000",
            "PGID=1000",
          ]
          mounts = {
            radarr_config = {
              source = "/mnt/bindmounts/prowlarr_config"
              target = "/config"
            }
          }
          lsio_mods_tailscale_enabled = true
          lsio_mods_tailscale_vars = {
            tailscale_serve_port = 9696
          }
        }
        sonarr = {
          image   = "lscr.io/linuxserver/sonarr:latest"
          network = ["download"]
          env = [
            "TZ=Europe/Brussels",
            "PUID=1000",
            "PGID=1000",
          ]
          mounts = {
            config = {
              source = "/mnt/bindmounts/sonarr_config"
              target = "/config"
            }
            downloads = {
              source = "/media/downloads"
              target = "/downloads"
            }
            movies = {
              source = "/media/videos/"
              target = "/tv"
            }
          }
          lsio_mods_tailscale_enabled = true
          lsio_mods_tailscale_vars = {
            tailscale_serve_port = 8989
          }
        }
        bazarr = {
          image   = "lscr.io/linuxserver/bazarr:latest"
          network = ["download"]
          env = [
            "TZ=Europe/Brussels",
            "PUID=1000",
            "PGID=1000",
          ]
          mounts = {
            config = {
              source = "/mnt/bindmounts/bazarr_config"
              target = "/config"
            }
            downloads = {
              source = "/media/downloads"
              target = "/downloads"
            }
            movies = {
              source = "/media/videos/hdmovies"
              target = "/movies"
            }
            series = {
              source = "/media/videos/series"
              target = "/tv/series"
            }
          }
          lsio_mods_tailscale_enabled = true
          lsio_mods_tailscale_vars = {
            tailscale_serve_port = 6767
          }
        }
        lidarr = {
          image   = "lscr.io/linuxserver/lidarr:latest"
          network = ["download"]
          env = [
            "TZ=Europe/Brussels",
            "PUID=1000",
            "PGID=1000",
          ]
          mounts = {
            config = {
              source = "/mnt/bindmounts/lidarr_config"
              target = "/config"
            }
            downloads = {
              source = "/media/downloads"
              target = "/downloads"
            }
            movies = {
              source = "/media/music"
              target = "/music"
            }
          }
          lsio_mods_tailscale_enabled = true
          lsio_mods_tailscale_vars = {
            tailscale_serve_port = 8686
          }
        }
        pinchflat = {
          image   = "ghcr.io/kieraneglin/pinchflat:latest"
          network = ["download"]
          env = [
            "TZ=Europe/Brussels",
          ]
          mounts = {
            ytdl = {
              source = "/media/videos/ytdl"
              target = "/downloads"
            }
          }
          volumes = {
            pinchflat_config = {
              container_path = "/config"
            }
          }
        }
        transmission = {
          image   = "lscr.io/linuxserver/transmission:latest"
          network = ["download"]
          env = [
            "TZ=Europe/Brussels",
            "PUID=1000",
            "PGID=1000",
          ]
          mounts = {
            config = {
              source = "/mnt/bindmounts/transmission_config"
              target = "/config"
            }
            downloads = {
              source = "/media/downloads"
              target = "/downloads"
            }
          }
          ports = {
            torrent = {
              internal = 51413
              external = 51413
              protocol = "udp"
            }
          }
          lsio_mods_tailscale_enabled = true
          lsio_mods_tailscale_vars = {
            tailscale_serve_port = 9091
          }
        }
        qbit = {
          image   = "lscr.io/linuxserver/qbittorrent:latest"
          network = ["download"]
          env = [
            "TZ=Europe/Brussels",
            "PUID=1000",
            "PGID=1000",
          ]
          volumes = {
            qbit_config = {
              container_path = "/config"
            }
          }
          mounts = {
            downloads = {
              source = "/media/downloads"
              target = "/downloads"
            }
          }
          ports = {
            torrent = {
              internal = 6881
              external = 6881
            }
          }
          labels = {
            traefik_port = {
              label = "traefik.http.services.portainer.loadbalancer.server.port"
              value = "8080"
            }
          }
          lsio_mods_tailscale_enabled = true
          lsio_mods_tailscale_vars = {
            tailscale_serve_port = 8080
          }
        }
        jellyfin = {
          image   = "lscr.io/linuxserver/jellyfin:latest"
          network = ["download"]
          env = [
            "TZ=Europe/Brussels",
            "PUID=1000",
            "PGID=1000",
          ]
          volumes = {
            jellyfin_config = {
              container_path = "/config"
            }
          }
          ports = {
            jellyfin = {
              internal = 8096
              external = 8096
            }
          }
          mounts = {
            downloads = {
              source = "/media/videos"
              target = "/tv"
            }
          }
          lsio_mods_tailscale_enabled = true
          lsio_mods_tailscale_vars = {
            tailscale_serve_port = 8096
          }
        }
        kuma = {
          image   = "louislam/uptime-kuma:2"
          network = ["kuma"]
          mounts = {
            kuma_config = {
              source = "/mnt/bindmounts/uptime-kuma"
              target = "/app/data"
            }
          }
        }
        search = {
          image   = "searxng/searxng:latest"
          network = ["searxng"]
          env = [
            "TZ=Europe/Brussels",
            "SEARXNG_BASE_URL=https://search.${local.domain_home}",
          ]
          volumes = {
            searxng_config = {
              container_path = "/etc/searxng"
            }
          }
        }
        ittools = {
          image   = "sharevb/it-tools:latest"
          network = ["download"]
        }
        rss = {
          image   = "lscr.io/linuxserver/freshrss:latest"
          network = ["download"]
          env = [
            "TZ=Europe/Brussels",
            "PUID=1000",
            "PGID=1000",
          ]
          volumes = {
            freshrss_config = {
              container_path = "/config"
            }
          }
          lsio_mods_tailscale_enabled = true
          lsio_mods_tailscale_vars = {
            tailscale_serve_port = 80
            tailscale_hostname   = "rss"
          }
        }
        firefly_db = {
          image   = "lscr.io/linuxserver/mariadb:latest"
          restart = "unless-stopped"
          network = ["firefly"]
          env = [
            "TZ=Europe/Brussels",
            "PUID=1000",
            "PGID=1000",
            "MYSQL_USER=firefly",
            "MYSQL_PASSWORD=${random_password.this["lxc-docker3.firefly_db_pwd"].result}",
            "MYSQL_ROOT_PASSWORD=${random_password.this["lxc-docker3.firefly_db_root_pwd"].result}",
            "MYSQL_DATABASE=firefly"
          ]
          volumes = {
            firefly_db_config = {
              container_path = "/config"
            }
          }
        }
        wallabag = {
          image   = "wallabag/wallabag:latest"
          restart = "unless-stopped"
          network = ["wallabag"]
          env = [
            "SYMFONY__ENV__SECRET=${random_password.this["lxc-docker3.wallabag_env_secret"].result}",
            "SYMFONY__ENV__DOMAIN_NAME=https://wallabag.${local.domain_home}",
            "POPULATE_DATABASE=True"
          ]
          volumes = {
            wallabag_data = {
              container_path = "/var/www/wallabag/dat"
            }
          }
        }
        flaresolverr = {
          image   = "ghcr.io/flaresolverr/flaresolverr:latest"
          restart = "unless-stopped"
          network = ["download"]
        }
        portainer = {
          image   = "portainer/portainer-ce:latest"
          restart = "unless-stopped"
          network = ["portainer"]
          volumes = {
            portainer_data = {
              container_path = "/data"
            }
          }
          mounts = {
            docker_sock = {
              source    = "/var/run/docker.sock"
              target    = "/var/run/docker.sock"
              type      = "bind"
              read_only = true
            }
          }
          labels = {
            traefik_port = {
              label = "traefik.http.services.portainer.loadbalancer.server.port"
              value = "9443"
            }
          }
        }
        samba = {
          image                  = "dperson/samba:latest"
          network                = ["samba"]
          docker_traefik_enabled = false
          env = [
            "TZ=Europe/Brussels",
            "USERID=1000",
            "GROUPID=1000",
            "SHARE1=videos;/mnt/videos/;yes;no;no;tim",
            "SHARE2=pictures;/mnt/pictures/;yes;no;no;tim",
            "SHARE3=downloads;/mnt/downloads/;yes;no;no;tim",
            "SHARE4=homeassistant;/mnt/dump/homeassistant;yes;no;no;tim,hassio",
            "USER=tim;${random_password.this["lxc-docker3.samba_user_tim"].result}",
            "USER=hassio;${random_password.this["lxc-docker3.samba_user_hassio"].result}"
          ]
          ports = {
            samba_tcp = {
              internal = 139
              external = 139
              protocol = "tcp"
            }
            samba_udp = {
              internal = 445
              external = 445
              protocol = "tcp"
            }
          }
          mounts = {
            downloads = {
              source = "/media/downloads"
              target = "/mnt/downloads"
              type   = "bind"
            }
            videos = {
              source = "/media/videos"
              target = "/mnt/videos"
              type   = "bind"
            }
            pictures = {
              source = "/media/pictures"
              target = "/mnt/pictures"
              type   = "bind"
            }
            dump = {
              source = "/media/dump"
              target = "/mnt/dump"
              type   = "bind"
            }
          }
        }
        traefik = {
          image                  = "traefik:latest"
          network                = ["traefik", "download", "web", "portainer", "searxng", "firefly", "wallabag", "kuma", "samba", "tsdproxy", "jellyfin", "healthchecks"]
          docker_traefik_enabled = false
          ports = {
            traefik_http = {
              internal = 80
              external = 80
            }
            traefik_https = {
              internal = 443
              external = 443
            }
            traefik_dashboard = {
              internal = 8080
              external = 8081
            }
          }
          mounts = {
            docker_sock = {
              source    = "/var/run/docker.sock"
              target    = "/var/run/docker.sock"
              type      = "bind"
              read_only = true
            }
          }
          uploads = merge(
            {
              traefik_dynamic = {
                content_base64 = base64encode(local.traefik_dynamic_config)
                file           = "/etc/traefik/dynamic/traefik_dynamic.yml"
              }
              traefik_static = {
                content_base64 = base64encode(local.traefik_static_config)
                file           = "/etc/traefik/traefik.yml"
              }
            },
            {
              for cert in local.flattened_certificates : "${cert.name}.${cert.file}" => {
                content = cert.content
                file    = "/etc/traefik/ssl/${cert.name}.${cert.file}"
              }
            }
          )
          command = [
            "--configFile=/etc/traefik/traefik.yml"
          ]
        }
        hishtory = {
          image   = "lscr.io/linuxserver/hishtory-server:latest"
          network = ["download"]
          env = [
            "TZ=Europe/Brussels",
            "PUID=1000",
            "PGID=1000",
            "HISHTORY_SQLITE_DB=/config/hishtory.db"
          ]
          volumes = {
            hishtory_config = {
              container_path = "/config"
            }
          }
          lsio_mods_tailscale_enabled = true
          lsio_mods_tailscale_vars = {
            tailscale_serve_port = 8080
            tailscale_hostname   = "hishtory"
          }
        }
        giftmanager = {
          image   = "icbest/giftmanager:latest"
          network = ["web"]
          volumes = {
            giftmanager_data = {
              container_path = "/app/data"
            }
          }
          labels = {
            tsdproxy_enable = {
              label = "tsdproxy.enable"
              value = true
            },
            tsdproxy_container_port = {
              label = "tsdproxy.port.1"
              value = "443/https:5000/http"
            }
          }
          ports = {
            traefik_http = {
              internal = 5000
              external = 5001
            }
          }
        }
        yrouter = {
          image   = "ghcr.io/timvy/y-router:main"
          network = ["web"]
        }
        tsdproxy = {
          image   = "almeidapaulopt/tsdproxy:2"
          network = ["traefik", "download", "web", "portainer", "searxng", "firefly", "wallabag", "kuma", "samba", "tsdproxy", "jellyfin", "healthchecks"]
          volumes = {
            tsdproxy_data = {
              container_path = "/data"
            }
            tsdproxy_config = {
              container_path = "/config"
            }
          }
          mounts = {
            docker_sock = {
              source    = "/var/run/docker.sock"
              target    = "/var/run/docker.sock"
              type      = "bind"
              read_only = true
            }
          }
          hosts = {
            gateway = {
              host = "host.docker.internal"
              ip   = "host-gateway"
            }
          }
          uploads = merge(
            {
              tsdproxy_config = {
                content_base64 = base64encode(local.tsdproxy_config)
                file           = "/config/tsdproxy.yaml"
              }
            },
            {
              for k, v in local.tsdproxy_lists : "tsdproxy_${k}" => {
                content_base64 = base64encode(v)
                file           = "/config/${k}.yaml"
              }
            }
          )
        }
      }
    }

    # Example of how to add a second host
    # lxc-docker4 = {
    #   host     = "ssh://ansible@lxc-docker4.internal:22"
    #   ssh_opts = ["-o", "ControlMaster=auto", "-o", "ControlPath=~/.ssh/control-%C", "-o", "ControlPersist=yes", "-o", "StrictHostKeyChecking=no", "-o", "IdentityFile=~/.ssh/semaphore_homelab.key"]
    #
    #   networks = {
    #     apps = {}
    #     monitoring = {}
    #   }
    #
    #   secrets = {
    #     app_secret = {}
    #   }
    #
    #   containers = {
    #     nginx = {
    #       image   = "nginx:latest"
    #       network = ["apps"]
    #       ports = {
    #         http = {
    #           internal = 80
    #           external = 8080
    #         }
    #       }
    #     }
    #   }
    # }
  }

  # Flatten networks for easy iteration
  flattened_networks = flatten([
    for host_name, host_config in local.docker_hosts : [
      for network_name, network_config in host_config.networks : {
        host    = host_name
        name    = network_name
        config  = network_config
      }
    ]
  ])

  # Create a map for easy lookup: "host.network" => config
  networks_map = {
    for net in local.flattened_networks : "${net.host}.${net.name}" => net
  }

  # Flatten secrets for easy iteration
  flattened_secrets = flatten([
    for host_name, host_config in local.docker_hosts : [
      for secret_name, secret_config in host_config.secrets : {
        host   = host_name
        name   = secret_name
        config = secret_config
      }
    ]
  ])

  # Create a map for secrets: "host.secret" => config
  secrets_map = {
    for secret in local.flattened_secrets : "${secret.host}.${secret.name}" => secret.config
  }

  # Merge all secrets for the global secrets local
  all_secrets = {
    for secret in local.flattened_secrets : "${secret.host}.${secret.name}" => secret.config
  }

  # Flatten containers for easy iteration
  flattened_containers = flatten([
    for host_name, host_config in local.docker_hosts : [
      for container_name, container_config in host_config.containers : {
        host   = host_name
        name   = container_name
        config = container_config
      }
    ]
  ])

  # Create a map for containers: "host.container" => config
  containers_map = {
    for container in local.flattened_containers : "${container.host}.${container.name}" => container.config
  }
}
