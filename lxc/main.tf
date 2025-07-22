resource "zfs_dataset" "infra" {
  for_each   = local.zfs-infra
  name       = each.value.name
  mountpoint = "/${each.value.name}"
}

resource "zfs_dataset" "bindmounts" {
  for_each   = local.zfs-bindmounts
  name       = each.value.name
  mountpoint = "/${each.value.name}"
  uid        = 100000
  gid        = 100000
  lifecycle {
    ignore_changes = [
      # Ignore changes to uid and gid, because the container may have changed them to something local
      gid,
      uid
    ]
  }
}
locals {
  config = {
    name = "test2"

  }
}
module "lxc_container" {
  source = "../modules/lxc_container"

  for_each = local.lxc

  config   = try(each.value.config, local.config)
  hostname = each.key
  secrets  = try(each.value.secrets, null)
}



# resource "proxmox_lxc" "lxc-containers" {
#   for_each     = local.lxc-containers
#   hostname     = each.value.hostname
#   target_node  = var.target_node
#   ostemplate   = var.ostemplate[each.value.distro]
#   nameserver   = lookup(each.value, "nameserver", "192.168.6.8")
#   searchdomain = lookup(each.value, "searchdomain", "home.internal")

#   onboot       = lookup(each.value, "onboot", true)
#   start        = true
#   unprivileged = lookup(each.value, "unprivileged", true)

#   features {
#     fuse    = lookup(each.value, "fuse", false)
#     nesting = lookup(each.value, "nesting", false)
#     keyctl  = lookup(each.value, "keyctl", false)
#   }

#   # hardware
#   memory = lookup(each.value, "memory", null)
#   cores  = lookup(each.value, "cores", 2)
#   swap   = 512

#   ssh_public_keys = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFz8LS1rWMP8q+gHKr7ItVCZJKmTQuxcI+/hk3Oey1k9"

#   rootfs {
#     storage = lookup(each.value, "rootfs", "lxc-root")
#     size    = lookup(each.value, "rootfs_size", "16G")
#   }

#   dynamic "network" {
#     for_each = each.value.networks
#     content {
#       name   = "eth${network.key}"
#       bridge = lookup(network.value, "bridge", "vmbr1")
#       ip     = network.value["ip"]
#       gw     = lookup(network.value, "gw", null)
#       tag    = network.value["tag"]
#     }
#   }

#   dynamic "mountpoint" {
#     for_each = each.value.mounts != "" ? each.value.mounts : []
#     content {
#       slot    = mountpoint.key
#       key     = mountpoint.key
#       storage = ""
#       volume  = mountpoint.value["volume"]
#       mp      = mountpoint.value["mp"]
#       size    = mountpoint.value["size"]
#     }
#   }

# provisioner "local-exec" {
#   command = "ansible-playbook playbooks/playbook_lxc_configure.yml -e 'hostname=${self.hostname} vmid=${regex("\\d+", "${self.id}")} state=present'"
# }
# provisioner "local-exec" {
#   when    = destroy
#   command = "ansible-playbook playbooks/playbook_lxc_configure.yml -e 'hostname=${self.hostname} vmid=${regex("\\d+", "${self.id}")} state=absent'"
# }
# provisioner "local-exec" {
#   command = (
#     each.value.distro == "alpine" ?
#     "ssh ${var.pm_user}@${var.pm_uri} pct exec ${regex("\\d+", "${self.id}")} apk add python3" :
#     "true"
#   )
# }
#   lifecycle {
#     ignore_changes = [
#       ssh_public_keys,
#       ostemplate,
#       rootfs
#     ]
#   }
# }
