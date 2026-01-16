# Dynamic Docker networks for all hosts
resource "docker_network" "networks" {
  for_each = local.networks_map

  provider = docker.hosts[split(".", each.key)[0]]
  name     = split(".", each.key)[1]
  driver   = lookup(each.value.config, "driver", "bridge")
}

locals {
  secrets = local.all_secrets
}

resource "random_password" "this" {
  for_each = local.secrets != null ? local.secrets : {}

  length  = try(each.value.length, "24")
  special = try(each.value.special, false)
}

resource "bitwarden_item_login" "this" {
  for_each = local.secrets != null ? local.secrets : {}

  name      = each.key
  password  = random_password.this[each.key].result
  folder_id = "3a1b0d22-efe3-46c0-ad34-aee901619f5e"
}

locals {
  domains = {
    home = {
      common_name = "*.${local.domain_home}"
    }
    nextcloud = {
      common_name = "nextcloud.${local.domain_home}"
    }
  }
}

data "bitwarden_secret" "certificates" {
  for_each = merge(
    { for domain, config in local.domains : "${domain}_fullchain" => { key = "certificate_${config.common_name}_fullchain" } },
    { for domain, config in local.domains : "${domain}_privkey" => { key = "certificate_${config.common_name}_privkey" } }
  )

  key = each.value.key
}

locals {
  flattened_certificates = flatten([
    for domain, config in local.domains : [
      {
        name    = domain
        file    = "fullchain.pem"
        content = data.bitwarden_secret.certificates["${domain}_fullchain"].value
      },
      {
        name    = domain
        file    = "privkey.pem"
        content = data.bitwarden_secret.certificates["${domain}_privkey"].value
      }
    ]
  ])
}

# Dynamic Docker containers for all hosts
module "docker_containers" {
  for_each    = local.containers_map
  source      = "./modules/docker_svc"
  domain_home = local.domain_home
  providers = {
    docker = docker.hosts[split(".", each.key)[0]]
  }

  # Extract host and container names
  docker_container_name = split(".", each.key)[1]

  # Container configuration
  image                       = each.value.image
  docker_network_name         = each.value.network
  docker_env_variables        = lookup(each.value, "env", [])
  docker_volumes              = lookup(each.value, "volumes", {})
  docker_mounts               = lookup(each.value, "mounts", {})
  docker_ports                = lookup(each.value, "ports", {})
  hosts                       = lookup(each.value, "hosts", {})
  lsio_mods_tailscale_enabled = lookup(each.value, "lsio_mods_tailscale_enabled", false)
  lsio_mods_tailscale_vars    = lookup(each.value, "lsio_mods_tailscale_vars", null)
  secrets                     = lookup(each.value, "secrets", null)
  docker_traefik_enabled      = lookup(each.value, "docker_traefik_enabled", true)
  docker_labels               = lookup(each.value, "labels", {})
  docker_command              = lookup(each.value, "command", null)
  uploads                     = lookup(each.value, "uploads", null)
}
