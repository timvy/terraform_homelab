locals {
  lxc = {
    "lxc-cloud" = {
      config = {
        distro  = "debian"
        memory  = "4096"
        tags    = "nextcloud"
        nesting = true
        keyctl  = true
        mounts = {
          nextcloud_data = {
            "volume" = "/nvme/bindmounts/nextcloud_data/"
            "mp"     = "/data/nextcloud"
            "size"   = "1000G"
          }
        }
        networks = {
          "eth0" = {
            ip  = "192.168.6.7/24"
            gw  = "192.168.6.1"
            tag = "6"
          }
        }
      }
      secrets = {
        nextcloud_db_pwd = {
          special = false
        }
        nextcloud_mysql_root_pwd = {
          special = false
        }
        nextcloud_admin_pwd = {}
      }

    },
    "lxc-docker3" = {
      config = {
        distro  = "debian"
        memory  = "8192"
        cores   = "4"
        tags    = "docker;tailscale"
        nesting = true
        keyctl  = true
        mounts = {
          volumes = {
            "volume" = "/nvme/lz4/binds/docker3_volumes/"
            "mp"     = "/var/lib/docker/volumes"
            "size"   = "1000G"
          },
          media = {
            "volume" = "/mnt/merger/media"
            "mp"     = "/media"
            "size"   = "10000G"
          }
          "timemachine" = {
            "volume" = "/mnt/samsung_pm/binds/samba_data_tm"
            "mp"     = "/timemachine"
            "size"   = "1000G"
          },
        }

        location_config = "/var/lib/docker"
        networks = {
          "eth0" = {
            ip  = "192.168.6.10/24"
            gw  = "192.168.6.1"
            tag = "6"
          }
        }
      }
    },
    "lxc-podman" = {
      config = {
        distro  = "debian"
        memory  = "2048"
        cores   = "4"
        tags    = "podman;tailscale"
        nesting = true
        keyctl  = true
      }
    },
    "lxc-kuma" = {
      config = {
        distro = "debian12"
        tags   = "kuma;tailscale"
      }
    },
    "lxc-syslog" = {
      config = {
        distro = "debian12"
        tags   = "syslogng;tailscale"
        #   splunk_inputs_monitor_logfile = {
        #     "syslog_remote" = {
        #       sourcetype = "syslog"
        #       index      = "syslog"
        #     }
        # }
      }
    },
    "lxc-tailscale" = {
      config = {
        hostname = "lxc-tailscale"
        distro   = "ubuntu"
        cores    = "4"
        tags     = "tailscale"
      }
    },
    "lxc-telegraf" = {
      config = {
        distro = "debian12"
        tags   = "tailscale;telegraf"
      }
    },
    "lxc-pihole2" = {
      config = {
        hostname = "lxc-pihole"
        distro   = "debian12"
        nesting  = true
        tags     = "pihole;tailscale"
        "networks" = {
          "eth0" = {
            "ip"  = "192.168.6.8/24"
            "gw"  = "192.168.6.1"
            "tag" = "6"
          }
        }
        splunk_inputs_monitor_logfile = {
          "pihole/pihole.log" = {
            sourcetype = "pihole"
            index      = "pihole"
          },
          "pihole/FTL.log" = {
            sourcetype = "Pihole-FTL"
            index      = "pihole"
          }
        }
      }
    },
    "lxc-splunk" = {
      config = {
        hostname = "lxc-splunk"
        distro   = "ubuntu"
        memory   = "8192"
        cores    = "4"
        tags     = "tailscale"
        "networks" = {
          "eth0" = {
            ip  = "dhcp"
            tag = null
        } }
        location_config = "/opt/splunk/"
        location_data   = "/opt/splunkdata/"
        size_data       = "100G"
        mounts = {
          "syslog_ng" = {
            "volume" = "/nvme/lz4/binds/lxc-syslog_data/"
            "mp"     = "/data"
            "size"   = "100G"
          },
          "syslog_pve" = {
            "volume" = "/var/log"
            "mp"     = "/mnt/logs/pve-hpe"
            "size"   = "100G"
          },
      } }
    },
    "lxc-samba" = {
      config = {
        hostname = "lxc-samba"
        distro   = "debian12"
        tags     = "samba;tailscale;timemachine"
        mounts = {
          "timemachine" = {
            "volume" = "/mnt/samsung_pm/binds/samba_data_tm"
            "mp"     = "/timemachine"
            "size"   = "1000G"
          },
        }
        "networks" = {
          "eth0" = {
            "ip"  = "192.168.6.15/24"
            "gw"  = "192.168.6.1"
            "tag" = "6"
          }
        }
      },
    }
    "lxc-timemachine" = {
      config = {
        hostname = "lxc-timemachine"
        distro   = "debian12"
        tags     = "samba;tailscale;timemachine"
        mounts = {
          "timemachine" = {
            "volume" = "/mnt/samsung_pm/binds/samba_data_tm"
            "mp"     = "/timemachine"
            "size"   = "600G"
          },
        }
        "networks" = {
          "eth0" = {
            "ip"  = "192.168.2.15/24"
            "gw"  = "192.168.2.1"
            "tag" = "2"
          }
        }
      },
    }
    "lxc-qbit" = {
      config = {
        hostname = "lxc-qbit"
        distro   = "debian"
        tags     = "qbit;ssh;tailscale"
        memory   = "4096"
        nesting  = true
        cores    = "2"
      },
    }
    "lxc-ntfy" = {
      config = {
        hostname = "lxc-ntfy"
        distro   = "debian12"
        tags     = "ntfy;ssh;tailscale"
        memory   = "4096"
        nesting  = true
        cores    = "2"
      },
    }
    "lxc-semaphore" = {
      config = {
        hostname = "lxc-semaphore"
        distro   = "debian12"
        tags     = "semaphore;ssh;tailscale"
        memory   = "4096"
        nesting  = true
        cores    = "2"
        "networks" = {
          "eth0" = {
            ip  = "dhcp"
            tag = 2
          }
        }
      }
      secrets = {
        hash = {
          length = 32
        }
        encryption = {
          length = 32
        }
        key = {
          length = 32
        }
        admin = {}
      },
    },
    "lxc-pangolin" = {
      config = {
        hostname = "lxc-pangolin"
        distro   = "debian12"
        tags     = "pangolin;ssh;tailscale"
        memory   = "4096"
        nesting  = true
        cores    = "2"
        "networks" = {
          "eth0" = {
            ip  = "dhcp"
            tag = 2
        } }
      },
    },

  }
}
