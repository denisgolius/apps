variable "app_name" {
  type    = string
  default = "ruby"
}

variable "app_version" {
  type    = string
  default = "3"
}

variable "hcloud_image" {
  type    = string
  default = "ubuntu-22.04"
}

build {
  sources = ["source.hcloud.autogenerated_1"]

  provisioner "shell" {
    inline = ["cloud-init status --wait"]
  }

  provisioner "shell" {
    environment_vars = ["DEBIAN_FRONTEND=noninteractive", "LC_ALL=C", "LANG=en_US.UTF-8", "LC_CTYPE=en_US.UTF-8"]
    scripts          = ["apps/shared/scripts/apt-upgrade.sh", "apps/hetzner/ruby/scripts/ruby.sh", "apps/shared/scripts/cleanup.sh"]
  }

}
