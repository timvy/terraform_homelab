
variable "docker_host" {
  default = "lxc-docker3.internal"
}

variable "docker_network_name" {
}

variable "image" {
}

variable "lsio_mods_tailscale_enabled" {
  default = false
}

variable "lsio_mods_tailscale_vars" {
  type = object({
    tailscale_hostname   = optional(string)
    tailscale_serve_port = number
    tailscale_serve_mode = optional(string)
  })
  default = {
    tailscale_hostname   = null
    tailscale_serve_port = null
    tailscale_serve_mode = null
  }
}

variable "lsio_mods" {
  default = {}
  type = map(object({
    name           = string
    container_path = string
  }))
}

variable "docker_volumes" {
  default = null
}

variable "docker_mounts" {
  default = null
}

variable "docker_container_name" {
}

variable "docker_container_hostname" {
  default = null
}

variable "docker_network_mode" {
  default = "bridge"
}

variable "docker_env_variables" {
  default = null
}

variable "docker_ports" {
  default = null
}

variable "docker_labels" {
  default = null
}

variable "docker_command" {
  default = null
}

variable "docker_traefik_enabled" {
  default = true
}

variable "domain_home" {
  type = any
}

variable "secrets" {
  default = null
}

variable "uploads" {
  default = null
}

variable "devices" {
  default = null
}
