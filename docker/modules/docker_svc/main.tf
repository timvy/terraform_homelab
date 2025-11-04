data "docker_registry_image" "this" {
  name = var.image
}

resource "docker_image" "this" {
  name          = data.docker_registry_image.this.name
  pull_triggers = [data.docker_registry_image.this.sha256_digest]
}

resource "pihole_dns_record" "this" {
  count = var.docker_traefik_enabled == true ? 1 : 0

  domain = "${var.docker_container_name}.${var.domain_home}"
  ip     = local.web_host_ip
}

resource "random_password" "this" {
  for_each = var.secrets != null ? var.secrets : {}

  length  = try(each.value.length, "24")
  special = try(each.value.special, null)
}

resource "tailscale_tailnet_key" "this" {
  count = var.lsio_mods_tailscale_enabled == true ? 1 : 0

  reusable      = false
  ephemeral     = false
  preauthorized = true
  expiry        = 7776000
}

resource "docker_volume" "this" {
  for_each = local.docker_volumes != null ? local.docker_volumes : {}

  name = lookup(each.value, "name", each.key)
}

resource "docker_container" "this" {
    lifecycle {
  }
  name         = var.docker_container_name
  hostname     = var.docker_container_hostname != null ? var.docker_container_hostname : var.docker_container_name
  image        = docker_image.this.image_id
  network_mode = var.docker_network_mode
  dynamic "networks_advanced" {
    for_each = var.docker_network_name != null ? var.docker_network_name : []
    content {
      name = networks_advanced.value
    }
  }
  restart = "unless-stopped"

  env = local.docker_env_vars

  dynamic "volumes" {
    for_each = local.docker_volumes != null ? local.docker_volumes : {}
    content {
      volume_name    = lookup(volumes.value, "name", volumes.key)
      container_path = volumes.value.container_path
    }
  }
  dynamic "ports" {
    for_each = var.docker_ports != null ? var.docker_ports : {}
    content {
      internal = ports.value.internal
      external = lookup(ports.value, "external", ports.value.internal)
      protocol = lookup(ports.value, "protocol", "tcp")
    }
  }
  dynamic "mounts" {
    for_each = var.docker_mounts != null ? var.docker_mounts : {}
    content {
      source = mounts.value.source
      target = mounts.value.target
      type   = lookup(mounts.value, "type", "bind")
      read_only = lookup(mounts.value, "read_only", false)
    }
  }
  dynamic "host" {
    for_each = var.hosts != null ? var.hosts : {}
    content {
      host = host.value.host
      ip   = host.value.ip
    }
    }
  dynamic "labels" {
    for_each = local.docker_labels != null ? local.docker_labels : {}
    content {
      label = labels.value.label
      value = labels.value.value
    }
  }
  dynamic "upload" {
    for_each = var.uploads != null ? var.uploads : {}
    content {
      content = lookup(upload.value, "content", null)
      content_base64 = lookup(upload.value, "content_base64", null)
      file    = upload.value.file
    }
  }
  dynamic "devices" {
    for_each = var.devices != null ? var.devices : {}
    content {
      host_path      = devices.value.host_path
      container_path = devices.value.container_path
      permissions    = devices.value.permissions
    }
  }
  command = var.docker_command != null ? var.docker_command : null
}
