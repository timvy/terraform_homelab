# Docker hosts configuration
# Define all Docker hosts and their configurations here

locals {
  # Define Docker hosts (static only - no dynamic values)
  docker_hosts = {
    lxc-docker3 = {
      host     = "ssh://ansible@lxc-docker3.internal:22"
      ssh_opts = ["-o", "ControlMaster=auto", "-o", "ControlPath=~/.ssh/control-%C", "-o", "ControlPersist=yes", "-o", "StrictHostKeyChecking=no", "-o", "IdentityFile=~/.ssh/semaphore_homelab.key"]
    }
  }

  # Define networks per host
  docker_networks = {
    lxc-docker3 = {
      authentik    = {}
      healthchecks = {}
      download     = {}
      hedgedoc     = {}
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

    # lxc-docker4 = {
    #   apps = {}
    #   monitoring = {}
    # }
  }

  # Define secrets per host
  docker_secrets = {
    lxc-docker3 = {
      authentik_db_pwd = {}
      authentik_secret = {
        length = 64
      }
      firefly_db_root_pwd = {}
      firefly_db_pwd      = {}
      firefly_app_key     = {}
      hedge_db_pwd        = {}
      wallabag_env_secret = {}
      samba_user_tim = {
        length = 32
      }
      samba_user_hassio = {
        length = 32
      }
      traefik_admin_user = {}
    }

    # lxc-docker4 = {
    #   app_secret = {}
    # }
  }

  # Define containers per host (static configuration only)
  docker_containers = {
    lxc-docker3 = {
      authentik_db = {
        image                  = "postgres:15-alpine"
        restart                = "unless-stopped"
        network                = [docker_network.networks["lxc-docker3.authentik"].name]
        docker_traefik_enabled = false
        env = [
          "POSTGRES_USER=authentik",
          "POSTGRES_PASSWORD=${random_password.this["lxc-docker3.authentik_db_pwd"].result}",
          "POSTGRES_DB=authentik"
        ]
        volumes = {
          authentik_db = {
            container_path = "/var/lib/postgresql/data"
          }
        }
      }
      authentik = {
        image   = "ghcr.io/goauthentik/server:latest"
        restart = "unless-stopped"
        network = [docker_network.networks["lxc-docker3.authentik"].name]
        env = [
          "AUTHENTIK_POSTGRESQL__HOST=authentik_db",
          "AUTHENTIK_POSTGRESQL__NAME=authentik",
          "AUTHENTIK_POSTGRESQL__PASSWORD=${random_password.this["lxc-docker3.authentik_db_pwd"].result}",
          "AUTHENTIK_POSTGRESQL__USER=authentik",
          "AUTHENTIK_REDIS__HOST=authentik_redis",
          "AUTHENTIK_SECRET_KEY=${random_password.this["lxc-docker3.authentik_secret"].result}",
        ]
        command = [
          "server"
        ]
      }
      authentik_redis = {
        image                  = "redis:7-alpine"
        restart                = "unless-stopped"
        network                = [docker_network.networks["lxc-docker3.authentik"].name]
        docker_traefik_enabled = false
        volumes = {
          authentik_redis = {
            container_path = "/data"
          }
        }
      }
      authentik_worker = {
        image                  = "ghcr.io/goauthentik/server:latest"
        restart                = "unless-stopped"
        network                = [docker_network.networks["lxc-docker3.authentik"].name]
        docker_traefik_enabled = false
        env = [
          "AUTHENTIK_POSTGRESQL__HOST=authentik_db",
          "AUTHENTIK_POSTGRESQL__NAME=authentik",
          "AUTHENTIK_POSTGRESQL__PASSWORD=${random_password.this["lxc-docker3.authentik_db_pwd"].result}",
          "AUTHENTIK_POSTGRESQL__USER=authentik",
          "AUTHENTIK_REDIS__HOST=authentik_redis",
          "AUTHENTIK_SECRET_KEY=${random_password.this["lxc-docker3.authentik_secret"].result}",
        ]
        command = [
          "worker"
        ]
      }
      firefly_db = {
        image   = "lscr.io/linuxserver/mariadb:latest"
        restart = "unless-stopped"
        network = [docker_network.networks["lxc-docker3.firefly"].name]
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
      healthchecks = {
        image   = "lscr.io/linuxserver/healthchecks:latest"
        network = [docker_network.networks["lxc-docker3.healthchecks"].name]
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
      hedge = {
        image   = "lscr.io/linuxserver/hedgedoc:latest"
        network = [docker_network.networks["lxc-docker3.hedgedoc"].name]
        env = [
          "TZ=Europe/Brussels",
          "PUID=1000",
          "PGID=1000",
          "HD_DATABASE_NAME=/config/hedgedoc.db",
          "HD_DATABASE_TYPE=sqlite",
          "CMD_DOMAIN=hedgedoc.${local.domain_tailscale}"
        ]
        volumes = {
          hedge = {
            container_path = "/config"
          }
        }
        lsio_mods_tailscale_enabled = true
        lsio_mods_tailscale_vars = {
          tailscale_serve_port = 3000
          tailscale_hostname   = "hedgedoc"
        }
      }
      radarr = {
        image   = "lscr.io/linuxserver/radarr:latest"
        network = [docker_network.networks["lxc-docker3.download"].name]
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
        network = [docker_network.networks["lxc-docker3.download"].name]
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
        network = [docker_network.networks["lxc-docker3.download"].name]
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
        network = [docker_network.networks["lxc-docker3.download"].name]
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
        network = [docker_network.networks["lxc-docker3.download"].name]
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
        network = [docker_network.networks["lxc-docker3.download"].name]
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
      qbit = {
        image   = "lscr.io/linuxserver/qbittorrent:latest"
        network = [docker_network.networks["lxc-docker3.download"].name]
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
        network = [docker_network.networks["lxc-docker3.download"].name]
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
        network = [docker_network.networks["lxc-docker3.kuma"].name]
        mounts = {
          kuma_config = {
            source = "/mnt/bindmounts/uptime-kuma"
            target = "/app/data"
          }
        }
      }
      search = {
        image   = "searxng/searxng:latest"
        network = [docker_network.networks["lxc-docker3.searxng"].name]
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
        network = [docker_network.networks["lxc-docker3.web"].name]
      }
      rss = {
        image   = "lscr.io/linuxserver/freshrss:latest"
        network = [docker_network.networks["lxc-docker3.download"].name]
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
      flaresolverr = {
        image   = "ghcr.io/flaresolverr/flaresolverr:latest"
        restart = "unless-stopped"
        network = [docker_network.networks["lxc-docker3.download"].name]
      }
      portainer = {
        image   = "portainer/portainer-ce:latest"
        restart = "unless-stopped"
        network = [docker_network.networks["lxc-docker3.portainer"].name]
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
      traefik = {
        image = "traefik:latest"
        network = [
          for network_name in keys(local.docker_networks.lxc-docker3) :
          docker_network.networks["lxc-docker3.${network_name}"].name
        ]
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
        network = [docker_network.networks["lxc-docker3.download"].name]
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
      samba = {
        image                  = "dperson/samba:latest"
        network                = [docker_network.networks["lxc-docker3.samba"].name]
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

      giftmanager = {
        image   = "icbest/giftmanager:latest"
        network = [docker_network.networks["lxc-docker3.web"].name]
        volumes = {
          giftmanager_data = {
            container_path = "/app/data"
          }
        }
      }
      wallabag = {
        image   = "wallabag/wallabag:latest"
        restart = "unless-stopped"
        network = [docker_network.networks["lxc-docker3.wallabag"].name]
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
      yrouter = {
        image   = "ghcr.io/timvy/y-router:main"
        network = [docker_network.networks["lxc-docker3.web"].name]
      }
      files = {
        image   = "nginx:trixie-perl"
        network = [docker_network.networks["lxc-docker3.web"].name]
        uploads = {
          media_shares = {
            content_base64 = base64encode(<<-EOF
              server {
                listen 80 default_server;
                listen [::]:80 default_server;
                server_name _;

                root /media/videos;
                # no index required — autoindex will show directory listing when no index.html
                autoindex on;
                autoindex_exact_size off;
                autoindex_localtime on;

                location / {
                  try_files $uri $uri/ =404;
                }

                # explicit alias for /videos/ if needed
                location /videos/ {
                  alias /media/videos/;
                  autoindex on;
                  autoindex_exact_size off;
                  autoindex_localtime on;
                }
              }
            EOF
            )
            file = "/etc/nginx/conf.d/media_shares.conf"
          }
        }
        mounts = {
          media = {
            source = "/media/videos"
            target = "/media/videos"
          }
        }
      }
      tsdproxy = {
        image = "almeidapaulopt/tsdproxy:2"
        network = [
          for network_name in keys(local.docker_networks.lxc-docker3) :
          docker_network.networks["lxc-docker3.${network_name}"].name
        ]
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

  # Flatten networks for easy iteration
  flattened_networks = flatten([
    for host_name, networks in local.docker_networks : [
      for network_name, network_config in networks : {
        host   = host_name
        name   = network_name
        config = network_config
      }
    ]
  ])

  # Create a map for easy lookup: "host.network" => config
  networks_map = {
    for net in local.flattened_networks : "${net.host}.${net.name}" => net
  }

  # Flatten secrets for easy iteration
  flattened_secrets = flatten([
    for host_name, secrets in local.docker_secrets : [
      for secret_name, secret_config in secrets : {
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

  # Flatten containers for easy iteration (static configs only)
  flattened_containers = flatten([
    for host_name, containers in local.docker_containers : [
      for container_name, container_config in containers : {
        host   = host_name
        name   = container_name
        config = container_config
      }
    ]
  ])

  # Create a map for containers: "host.container" => config (will be enhanced with dynamic env vars)
  containers_map = {
    for container in local.flattened_containers : "${container.host}.${container.name}" => container.config
  }
}
