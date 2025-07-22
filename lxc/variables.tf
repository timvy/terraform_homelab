variable "ssh_key" {
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDIP0Yus9s3/KEO+4OaZYpJBL1s0IepQURM/7sdSYluU2Sk1dbhJcB6ubT8dJ8AVkMoEDNhfj1vC0/JUNYFezkm/53MTtWqFUmvxY1mCmSWVE1a+nJZtMPE/sJBbbIT0z/s9Z7uxqSQbPbFXOo013vz5jzynePHASBEygrjnU72btFtWxmB3lmkoy7gZCdUwoN93UJOONlFMdiJb4SQJl2JA2THJLQyxkdF/A+aCK8jNEBYMFiYr31JDvQCsBonMqLO0HUkjziGn6LlT3mjXmHZ+vLEpRYvqOdLdnYzJvUaNhm+YSt7Qc8pbP8MooTp+uIvRZRH3ogScnq4uLuYwLpF timvandyck@Tims-MacBook-Pro.local"
}

variable "target_node" {
  default = "pve-hpe"
}

variable "ostemplate" {
  type = map(string)
  default = {
    "alpine"         = "local:vztmpl/alpine-3.15-default_20211202_amd64.tar.xz"
    "debian"         = "local:vztmpl/debian-13-standard_amd64.tar.xz"
    "ubuntu"         = "local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
    "ubuntu-minimal" = "local:vztmpl/ubuntu-22.04-minimal-cloudimg-amd64-root.tar.xz"
  }
}
