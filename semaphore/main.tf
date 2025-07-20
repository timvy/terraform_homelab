resource "semaphoreui_project" "homelab" {
  name     = "homelab"
  alert              = false
    max_parallel_tasks = 0
  }

data "bitwarden_secret" "ssh_semaphore_github" {
  key = "ssh_semaphore_github"
}

data "bitwarden_secret" "secret" {
  for_each = { for secret in local.bitwarden_secrets : secret.key => secret }
  key      = each.value.key
}

resource "semaphoreui_project_key" "project_keys" {
  for_each = local.project_keys

  project_id = semaphoreui_project.homelab.id
  name = each.key
  ssh = {
    private_key = each.value.private_key
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

resource "semaphoreui_project_environment" "environment" {
  for_each   = local.environments
  project_id = semaphoreui_project.homelab.id
  name       = each.value.name

  variables = { for k, v in each.value.variables : k => v }

  environment = { for k, v in each.value.environment : k => v }

  secrets = [for s in each.value.secrets : {
    name  = s.name
    value = s.value
    type  = s.type
  }]
}
