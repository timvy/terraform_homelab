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

# certs for traefik
data "terraform_remote_state" "certs" {
  backend = "s3"

  config = {
    bucket                      = "tofu-backend"
    key                         = "env:/certs/terraform.tfstate"
    region                      = "main" # this is required, but will be skipped!
    skip_credentials_validation = true   # this will skip AWS related validation
    skip_metadata_api_check     = true
  skip_region_validation = true }
}

locals {
  flattened_certificates = flatten([
    for name, certs in data.terraform_remote_state.certs.outputs.all_certificates : [
      {
        name    = name
        file    = "fullchain.pem"
        content = certs.fullchain
      },
      {
        name    = name
        file    = "privkey.pem"
        content = certs.privkey
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
