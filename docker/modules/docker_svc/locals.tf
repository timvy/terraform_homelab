locals {
  docker_volume_tailscale = var.lsio_mods_tailscale_enabled == true ? {
    tailscale = {
      name           = "${var.docker_container_name}_tailscale"
      container_path = "/var/lib/tailscale"
    }
  } : {}
  docker_volumes = merge(var.docker_volumes, local.docker_volume_tailscale)
  docker_env_vars_tailscale = var.lsio_mods_tailscale_enabled == true ? [
    "DOCKER_MODS=ghcr.io/tailscale-dev/docker-mod:main",
    "TAILSCALE_AUTHKEY=${tailscale_tailnet_key.this[0].key}",
    "TAILSCALE_STATE_DIR=/var/lib/tailscale",
    "TAILSCALE_HOSTNAME=${var.lsio_mods_tailscale_vars.tailscale_hostname != null ? var.lsio_mods_tailscale_vars.tailscale_hostname : var.docker_container_name}",
    "TAILSCALE_SERVE_PORT=${var.lsio_mods_tailscale_vars.tailscale_serve_port}",
    "TAILSCALE_SERVE_MODE=https"
  ] : []
  docker_env_vars = concat(var.docker_env_variables, local.docker_env_vars_tailscale)
  docker_labels_traefik = var.docker_traefik_enabled == true ? {
    rule = {
      label = "traefik.http.routers.${var.docker_container_name}.rule"
      value = "Host(`${var.docker_container_name}.${var.domain_home}`)"
    }
    tls = {
      label = "traefik.http.routers.${var.docker_container_name}.tls"
      value = "true"
    }
  } : {}
  docker_labels = merge(var.docker_labels, local.docker_labels_traefik)
}
