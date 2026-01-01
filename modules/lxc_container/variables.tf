variable "hostname" {
  type = string
}

variable "config" {
  description = "Map of the lxc configuration"
  type = object({
    tags         = optional(string, "")
    onboot       = optional(bool, true)
    start        = optional(bool, true)
    unprivileged = optional(bool, true)
    distro       = string
    memory       = optional(string, "1024")
    cores        = optional(string, "2")
    nameserver   = optional(string, "192.168.6.1")
    searchdomain = optional(string, "internal")

    fuse    = optional(bool, false)
    nesting = optional(bool, false)
    keyctl  = optional(bool, false)

    mounts = optional(map(object({
      volume = optional(string)
      mp     = optional(string)
      size   = optional(string)
    })))

    networks = optional(map(object({
      ip  = string
      tag = string
      gw  = optional(string)
    })))

    ssh_public_keys = optional(string, "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFz8LS1rWMP8q+gHKr7ItVCZJKmTQuxcI+/hk3Oey1k9")

    location_config = optional(string, "/config")
    location_data   = optional(string, "/data")
    location_logs   = optional(string, "/var/log")
    size_config     = optional(string, "10G")
    size_data       = optional(string, "10G")
    size_logs       = optional(string, "10G")

    splunk_inputs_monitor_logfile = optional(map(object({
      sourcetype = optional(string, "syslog")
      index      = optional(string, "syslog")
      host       = optional(string)
    })))
  })
}
variable "lxc_target_node" {
  default = "pve-hpe"
}

variable "lxc_ostemplate" {
  type = map(string)
  default = {
    "alpine"         = "local:vztmpl/alpine-3.15-default_20211202_amd64.tar.xz"
    "debian"         = "local:vztmpl/debian-13-standard_amd64.tar.xz"
    "debian12"       = "local:vztmpl/debian-12-standard_12.0-1_amd64.tar.zst"
    "ubuntu"         = "local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
    "ubuntu-minimal" = "local:vztmpl/ubuntu-22.04-minimal-cloudimg-amd64-root.tar.xz"
  }
}

variable "pm_user" {
  default = "root"
}
variable "pm_uri" {
  default = "100.81.115.2"
}
variable "zfs_logs" {
  default = "nvme/lz4/logs"
}
variable "zfs_binds" {
  default = "nvme/lz4/binds"
}
variable "secrets" {

  default = null
}

variable "splunk_inputs_monitor_syslog" {
  default = {
    "syslog" = {
      sourcetype = "syslog"
      index      = "syslog"
    }
  }
}
