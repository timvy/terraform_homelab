
resource "zfs_dataset" "logs" {
  name       = "${var.zfs_logs}/${var.hostname}"
  mountpoint = "/${var.zfs_logs}/${var.hostname}"
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

resource "zfs_dataset" "data" {
  name       = "${var.zfs_binds}/${var.hostname}_data"
  mountpoint = "/${var.zfs_binds}/${var.hostname}_data"
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

resource "zfs_dataset" "config" {
  name          = "${var.zfs_binds}/${var.hostname}_config"
  mountpoint    = "/${var.zfs_binds}/${var.hostname}_config"
  uid           = 100000
  gid           = 100000
  lifecycle {
    ignore_changes = [
      # Ignore changes to uid and gid, because the container may have changed them to something local
      gid,
      uid
    ]
  }
}

locals {
  mounts = merge(
    var.config.mounts,
    {
      "logs" = {
        "volume" = zfs_dataset.logs.mountpoint
        "mp"     = var.config.location_logs
        "size"   = var.config.size_logs
      },
      "config" = {
        "volume" = zfs_dataset.config.mountpoint,
        "mp"     = var.config.location_config,
        "size"   = var.config.size_config
      },
      "data" = {
        "volume" = zfs_dataset.data.mountpoint,
        "mp"     = var.config.location_data,
        "size"   = var.config.size_data
      }
    }
  )
  network_default = {
    "eth0" = {
      ip  = "dhcp"
      tag = "6"
      gw  = ""
  } }

  networks = var.config.networks != null ? var.config.networks : local.network_default
}

resource "random_password" "this" {
  for_each = var.secrets != null ? var.secrets : {}

  length  = try(each.value.length, "24")
  special = try(each.value.special, null)
}

# resource "bitwarden_item_login" "this" {
#   for_each = var.secrets != null ? var.secrets : {}

#   name      = "${var.hostname}_${each.key}"
#   password  = random_password.this[each.key].result
#   folder_id = "3a1b0d22-efe3-46c0-ad34-aee901619f5e"
# }

resource "bitwarden_secret" "this" {
  for_each = var.secrets != null ? var.secrets : {}

  key      = "${var.hostname}_${each.key}"
  value  = random_password.this[each.key].result
  project_id = "8e37b6b5-0614-453e-bce3-b2f5009aec66"
  note = "${var.hostname}_${each.key}"
}

resource "tailscale_tailnet_key" "this" {
  count = contains(split(";", var.config.tags), "tailscale") ? 1 : 0

  reusable      = true
  ephemeral     = false
  preauthorized = true
  expiry        = 7776000

  lifecycle {
    create_before_destroy = true
  }
}

resource "proxmox_lxc" "this" {
  hostname     = var.hostname
  target_node  = var.lxc_target_node
  ostemplate   = var.lxc_ostemplate[var.config.distro]
  nameserver   = var.config.nameserver
  searchdomain = var.config.searchdomain

  onboot       = var.config.onboot
  start        = var.config.start
  unprivileged = var.config.unprivileged

  tags = var.config.tags

  features {
    fuse    = var.config.fuse
    nesting = var.config.nesting
    keyctl  = var.config.keyctl
  }

  # hardware
  memory = tonumber(var.config.memory)
  cores  = tonumber(var.config.cores)
  swap   = 512

  ssh_public_keys = var.config.ssh_public_keys

  rootfs {
    storage = "lxc-root"
    size    = "32G"
  }

  dynamic "network" {
    for_each = local.networks
    content {
      name   = network.key
      bridge = "vmbr1"
      ip     = network.value["ip"]
      gw     = network.value["gw"]
      tag    = network.value["tag"]
    }
  }

  dynamic "mountpoint" {
    for_each = local.mounts
    content {
      slot    = index(keys(local.mounts), mountpoint.key)
      key     = index(keys(local.mounts), mountpoint.key)
      storage = ""
      volume  = mountpoint.value["volume"]
      mp      = mountpoint.value["mp"]
      size    = mountpoint.value["size"]
    }
  }
  provisioner "local-exec" {
    command = (
      contains(split(";", var.config.tags), "tailscale") ?
      <<EOT
ansible all -i proxmox, -m ansible.builtin.lineinfile -a "path=/etc/pve/lxc/${regex("\\d+", "${self.id}")}.conf line='lxc.cgroup2.devices.allow: c 10:200 rwm' insertafter=EOF"
ansible all -i proxmox, -m ansible.builtin.lineinfile -a "path=/etc/pve/lxc/${regex("\\d+", "${self.id}")}.conf line='lxc.mount.entry: /dev/net/tun dev/net/tun none bind,create=file' insertafter=EOF"
EOT
      :
      "true"
    )
  }
  provisioner "local-exec" {
    command = (
      var.lxc_ostemplate[var.config.distro] == "alpine" ?
      "ssh ${var.pm_user}@${var.pm_uri} pct exec ${regex("\\d+", "${self.id}")} apk add python3" :
      "true"
    )
  }
  provisioner "local-exec" {
    command = <<EOT
sleep 10
# ansible all -i $IP_ADDRESS, -m ansible.builtin.apt -a "update_cache=yes name=* state=latest" -u root --ssh-extra-args="-o StrictHostKeyChecking=no -o GlobalKnownHostsFile=/dev/null -o UserKnownHostsFile=/dev/null"
ansible all -m ping -i local, -u root -c lxc_ssh -e "ansible_host=proxmox lxc_host=${regex("\\d+", "${self.id}")}"
ssh proxmox pct reboot ${regex("\\d+", "${self.id}")}

EOT
  }
  lifecycle {
    ignore_changes = [
      ssh_public_keys,
      ostemplate,
      rootfs
    ]
  }
  provisioner "local-exec" {
    command = (
      contains(split(";", var.config.tags), "tailscale") ?
      <<EOT
# ansible all -m ping -i local, -u root -c lxc_ssh -e "ansible_host=proxmox lxc_host=${regex("\\d+", "${self.id}")}"
ansible-playbook -i ${var.pm_uri}, ../../modules/lxc_container/playbooks/playbook_lxc_tailscale.yml --extra-vars 'ansible_host=proxmox lxc_host=${regex("\\d+", "${self.id}")} tailscale_authkey=${tailscale_tailnet_key.this[0].key}'
# ssh ${var.pm_user}@${var.pm_uri} pct exec ${regex("\\d+", "${self.id}")} -- apt install -y curl sudo
# ssh ${var.pm_user}@${var.pm_uri} pct exec ${regex("\\d+", "${self.id}")} -- curl https://tailscale.com/install.sh -o /tmp/tailscale_install.sh
# ssh ${var.pm_user}@${var.pm_uri} pct exec ${regex("\\d+", "${self.id}")} -- chmod +x /tmp/tailscale_install.sh
# ssh ${var.pm_user}@${var.pm_uri} pct exec ${regex("\\d+", "${self.id}")} -- /tmp/tailscale_install.sh
# ssh ${var.pm_user}@${var.pm_uri} pct exec ${regex("\\d+", "${self.id}")} -- sudo tailscale up --accept-dns=false --auth-key=${tailscale_tailnet_key.this[0].key}"

EOT
      :
      "true"
    )
  }
}

resource "splunk_inputs_monitor" "log" {
  for_each = merge(var.splunk_inputs_monitor_syslog, var.config.splunk_inputs_monitor_logfile)

  name       = "/mnt/logs/${var.hostname}/${each.key}"
  recursive  = false
  sourcetype = each.value.sourcetype
  index      = each.value.index
  # host       = each.value.host != null ? each.value.host : var.hostname
  host = lookup(each.value, "host", var.hostname)

  depends_on = [
    proxmox_lxc.this
  ]
}
