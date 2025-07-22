locals {
  zfs-infra = {
    "nvme_lz4_logs" = {
      "name" = "nvme/lz4/logs"
    },
  }
  zfs-bindmounts = {
    "samba_config" = {
      "name" = "nvme/bindmounts/samba_config"
    },
    "lms_config" = {
      "name" = "nvme/bindmounts/lms_config"
    },
    "docker3_bindmounts" = {
      "name" = "nvme/lz4/binds/docker3_bindmounts"
    },
    "docker1_bindmounts" = {
      "name" = "nvme/lz4/binds/docker3_bindmounts"
    },
    "docker1_dsmrdb1_data" = {
      "name" = "nvme/lz4/binds/docker3_bindmounts/dsmrdb1_data"
    },
    "docker1_dsmr1_backups" = {
      "name" = "nvme/lz4/binds/docker3_bindmounts/dsmr1_backups"
    },
    "docker1_dsmrdb2_data" = {
      "name" = "nvme/lz4/binds/docker3_bindmounts/dsmrdb2_data"
    },
    "docker1_dsmr2_backups" = {
      "name" = "nvme/lz4/binds/docker3_bindmounts/dsmr2_backups"
    },
    "docker1_bazarr_config" = {
      "name" = "nvme/lz4/binds/docker3_bindmounts/bazarr_config"
    },
    "docker1_prowlarr_config" = {
      "name" = "nvme/lz4/binds/docker3_bindmounts/prowlarr_config"
    },
    "docker1_radarr_config" = {
      "name" = "nvme/lz4/binds/docker3_bindmounts/radarr_config"
    },
    "docker1_sonarr_config" = {
      "name" = "nvme/lz4/binds/docker3_bindmounts/sonarr_config"
    },
    "docker1_lidarr_config" = {
      "name" = "nvme/lz4/binds/docker3_bindmounts/lidarr_config"
    },
    "docker1_jackett_config" = {
      "name" = "nvme/lz4/binds/docker3_bindmounts/jackett_config"
    },
    "docker1_jackett_downloads" = {
      "name" = "nvme/lz4/binds/docker3_bindmounts/jackett_downloads"
    },
    "docker1_transmission_config" = {
      "name" = "nvme/lz4/binds/docker3_bindmounts/transmission_config"
    },
    "docker1_nginx_db_mysql" = {
      "name" = "nvme/lz4/binds/docker3_bindmounts/nginx_db_mysql"
    },
    "docker1_nginx_data" = {
      "name" = "nvme/lz4/binds/docker3_bindmounts/nginx_data"
    },
    "docker1_nginx_letsencrypt" = {
      "name" = "nvme/lz4/binds/docker3_bindmounts/nginx_letsencrypt"
    },
    "docker1_wekanapp" = {
      "name" = "nvme/lz4/binds/docker3_bindmounts/wekanapp"
    },
    "docker1_wekandb" = {
      "name" = "nvme/lz4/binds/docker3_bindmounts/wekandb"
    },
    "docker1_nvme/uptime-kuma" = {
      "name" = "nvme/lz4/binds/docker3_bindmounts/uptime-kuma"
    },
    "docker2_bindmounts" = {
      "name" = "nvme/lz4/binds/docker2_bindmounts"
    },
    "docker2_homeassistant" = {
      "name" = "nvme/lz4/binds/docker3_bindmounts/homeassistant"
    },
    "docker2_deconz" = {
      "name" = "nvme/lz4/binds/docker3_bindmounts/deconz"
    },
    "docker2_hassdb_data" = {
      "name" = "nvme/lz4/binds/docker3_bindmounts/hassdb_data"
    },
    "docker2_hassdb_socket" = {
      "name" = "nvme/lz4/binds/docker3_bindmounts/hassdb_socket"
    },
    "docker2_zwavejs2mqtt" = {
      "name" = "nvme/lz4/binds/docker3_bindmounts/zwavejs2mqtt"
    },
    "docker2_openvscode" = {
      "name" = "nvme/lz4/binds/docker3_bindmounts/openvscode"
    },
    "homeassistant_config" = {
      "name" = "nvme/lz4/binds/homeassistant_config"
    },

  }
}