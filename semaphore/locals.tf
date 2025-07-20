locals {
  bitwarden_secrets = [
    {
      key = "ssh_semaphore_homelab"
    },
    {
      key = "ssh_semaphore_github"
    },
    {
      key = "proxmox_api_user"
    },
    {
      key = "proxmox_api_password"
    },
    {
      key = "minio_s3_url"
    },
    {
      key = "minio_tf_access_key"
    },
    {
      key = "minio_tf_secret"
    }
  ]
  project_keys = {
    semaphore_github = {
      private_key = data.bitwarden_secret.secret["ssh_semaphore_github"].value
    }
    semaphore_homelab = {
      private_key = data.bitwarden_secret.secret["ssh_semaphore_github"].value
    }
  }
  repositories = {
    terraform_homelab = {
      url        = "git@github.com:timvy/terraform_homelab.git"
    },
    ansible_inventory_homelab = {
      url        = "git@github.com:timvy/ansible_inventory_homelab.git"
    }
    ansible_collection_homelab = {
      url        = "git@github.com:timvy/ansible_collection_homelab.git"
  }
}
  environments = {
    proxmox = {
      name = "Proxmox Inventory"
      variables = {} 
      environment = {}
      secrets = [{
        name = "proxmox_host"
        value = "pve-hpe.${data.bitwarden_secret.domain_tailscale.value}"
        type = "var"
      }, {
        name = "PROXMOX_PASSWORD"
        value = data.bitwarden_secret.secret["proxmox_api_password"].value
        type = "env"
      }, {  
        name = "PROXMOX_USER"
        value = data.bitwarden_secret.secret["proxmox_api_user"].value
        type = "env"
      }, {  
        name = "PROXMOX_URL"
        value = "https://pve-hpe.${data.bitwarden_secret.domain_tailscale.value}"
        type = "env"
      }
      ]
    }
    terraform_homelab = {
      name = "Terraform Homelab"
      variables = {}
      environment = {}
      secrets = [{
        name = "AWS_ACCESS_KEY_ID"
        value = data.bitwarden_secret.secret["minio_tf_access_key"].value
        type = "env"
      }, {
        name = "AWS_SECRET_ACCESS_KEY"
        value = data.bitwarden_secret.secret["minio_tf_secret"].value
        type = "env"
      }, {
        name = "AWS_ENDPOINT_URL_S3"
        value = data.bitwarden_secret.secret["minio_s3_url"].value
        type = "env"
      }]
    }
  }

}
