resource "semaphoreui_project" "homelab" {
  name               = "homelab"
  alert              = false
  max_parallel_tasks = 0
}

data "bitwarden_secret" "secret" {
  for_each = { for secret in local.bitwarden_secrets : secret.key => secret }

  key = each.value.key
}

resource "semaphoreui_project_key" "project_keys" {
  for_each = local.project_keys

  project_id = semaphoreui_project.homelab.id
  name       = each.key
  ssh = {
    private_key = each.value.private_key
    user        = lookup(each.value, "user", "")
  }
}

resource "semaphoreui_project_repository" "repositories" {
  for_each = local.repositories

  project_id = semaphoreui_project.homelab.id
  name       = each.key
  url        = each.value.url
  branch     = "main"
  ssh_key_id = semaphoreui_project_key.project_keys["semaphore_github"].id
}

resource "semaphoreui_project_inventory" "inventory" {
  for_each = local.inventories

  project_id          = semaphoreui_project.homelab.id
  name                = each.value.name
  file                = lookup(each.value, "file", null)
  static              = lookup(each.value, "static", null)
  static_yaml         = lookup(each.value, "static_yaml", null)
  terraform_workspace = lookup(each.value, "terraform_workspace", null)
  ssh_key_id          = semaphoreui_project_key.project_keys["semaphore_homelab"].id
}

resource "semaphoreui_project_environment" "environment" {
  for_each    = local.environments
  project_id  = semaphoreui_project.homelab.id
  name        = each.value.name
  variables   = { for k, v in each.value.variables : k => v }
  environment = { for k, v in each.value.environment : k => v }
  secrets = [for s in each.value.secrets : {
    name  = s.name
    value = s.value
    type  = s.type
  }]
}

resource "semaphoreui_project_template" "task_ansible" {
  for_each = local.templates

  allow_override_args_in_task = true
  app                         = each.value.app
  description                 = each.value.description
  environment_id              = semaphoreui_project_environment.environment[each.value.environment].id
  inventory_id                = semaphoreui_project_inventory.inventory[each.value.inventory].id
  name                        = each.key
  playbook                    = each.value.playbook
  project_id                  = semaphoreui_project.homelab.id
  repository_id               = semaphoreui_project_repository.repositories[each.value.repository].id
  arguments                   = lookup(each.value, "arguments", null)
}
