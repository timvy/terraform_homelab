locals {
  docker_networks_lxc-docker3 = {
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

  secrets_lxc-docker3 = {
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

  docker_container_lxc-docker3 = {
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
      network = [docker_network.lxc-docker3["download"].name]
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
      network = [docker_network.lxc-docker3["download"].name]
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
      network = [docker_network.lxc-docker3["download"].name]
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
      network = [docker_network.lxc-docker3["download"].name]
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
      network = [docker_network.lxc-docker3["download"].name]
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
      network = [docker_network.lxc-docker3["download"].name]
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
      network = [docker_network.lxc-docker3["download"].name]
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
      network = [docker_network.lxc-docker3["download"].name]
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
      network = [docker_network.lxc-docker3["download"].name]
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
      network = [docker_network.lxc-docker3["kuma"].name]
      mounts = {
        kuma_config = {
          source = "/mnt/bindmounts/uptime-kuma"
          target = "/app/data"
        }
      }
    }
    search = {
      image   = "searxng/searxng:latest"
      network = [docker_network.lxc-docker3["searxng"].name]
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
      network = [docker_network.lxc-docker3["download"].name]
    }
    rss = {
      image   = "lscr.io/linuxserver/freshrss:latest"
      network = [docker_network.lxc-docker3["download"].name]
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
      network = [docker_network.lxc-docker3["firefly"].name]
      env = [
        "TZ=Europe/Brussels",
        "PUID=1000",
        "PGID=1000",
        "MYSQL_USER=firefly",
        "MYSQL_PASSWORD=${random_password.this["firefly_db_pwd"].result}",
        "MYSQL_ROOT_PASSWORD=${random_password.this["firefly_db_root_pwd"].result}",
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
      network = [docker_network.lxc-docker3["wallabag"].name]
      env = [
        "SYMFONY__ENV__SECRET=${random_password.this["wallabag_env_secret"].result}",
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
      network = [docker_network.lxc-docker3["download"].name]
    }
    portainer = {
      image   = "portainer/portainer-ce:latest"
      restart = "unless-stopped"
      network = [docker_network.lxc-docker3["portainer"].name]
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
      network                = [docker_network.lxc-docker3["samba"].name]
      docker_traefik_enabled = false
      env = [
        "TZ=Europe/Brussels",
        "USERID=1000",
        "GROUPID=1000",
        "SHARE1=videos;/mnt/videos/;yes;no;no;tim",
        "SHARE2=pictures;/mnt/pictures/;yes;no;no;tim",
        "SHARE3=downloads;/mnt/downloads/;yes;no;no;tim",
        "SHARE4=homeassistant;/mnt/dump/homeassistant;yes;no;no;tim,hassio",
        "USER=tim;${random_password.this["samba_user_tim"].result}",
        "USER=hassio;${random_password.this["samba_user_hassio"].result}"
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
      image = "traefik:latest"
      network = [for net in keys(local.docker_networks_lxc-docker3) : docker_network.lxc-docker3[net].name]

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
            content_base64 = base64encode(file("files/traefik/traefik_dynamic.yml"))
            file           = "/etc/traefik/dynamic/traefik_dynamic.yml"
          }
        },
        {
          for cert in local.flattened_certificates : "${cert.name}.${cert.file}" => {
            content = cert.content
            file    = "/etc/traefik/ssl/${cert.name}.${cert.file}"
          }
        }
      )
      labels = {
        admin-auth = {
          label = "traefik.http.middlewares.admin-auth.basicauth.users"
          value = "admin:${bcrypt(random_password.this["traefik_admin_user"].result)}"
        }
        api = {
          label = "traefik.http.routers.traefik.service=api@internal"
          value = "api@internal"
        }
        dashboard = {
          label = "traefik.http.routers.api.rule"
          value = "Host(`traefik.${local.domain_home}`) && (PathPrefix(`/api`) || PathPrefix(`/dashboard`))"
        }
        api_service = {
          label = "traefik.http.routers.api.service"
          value = "api@internal"
        }
        api_middlewares = {
          label = "traefik.http.routers.api.middlewares"
          value = "admin-auth"
        }
      }
      command = [
        "--accesslog=true",
        "--providers.file.directory=/etc/traefik/dynamic",
        "--providers.docker",
        "--entrypoints.http.address=:80",
        "--entrypoints.https.address=:443",
      ]
    }
    hishtory = {
      image   = "lscr.io/linuxserver/hishtory-server:latest"
      network = [docker_network.lxc-docker3["download"].name]
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
      network = [docker_network.lxc-docker3["web"].name]
      volumes = {
        giftmanager_data = {
          container_path = "/app/data"
        }
      }
      labels = {
        tsdproxy_enable = {
          label = "tsdproxy.enable"
          value = true
        }
      }
    }
    tsdproxy = {
      image   = "almeidapaulopt/tsdproxy:2"
      network = [for net in keys(local.docker_networks_lxc-docker3) : docker_network.lxc-docker3[net].name]
      volumes = {
        tsdproxy_data = {
          container_path = "/app/data"
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
      uploads = {
        tsdproxy_config = {
          content_base64 = base64encode(local.tsdproxy_config)
          file           = "/config/tsdproxy.yaml"
        }
      }
    }

  }
}
