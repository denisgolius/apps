
variable "app_name" {
  type    = string
  default = "nextcloud"
}

variable "app_version" {
  type    = string
  default = "25.0.2"
}

variable "app_checksum" {
  type    = string
  default = "369c65f48d8fc60676bde49237397b885afb9b58fdcabf84fdd21d8e9a7c3865"
}

variable "hcloud_image" {
  type    = string
  default = "ubuntu-22.04"
}

variable "apt_packages" {
  type    = string
  default = "apache2 php libapache2-mod-php php-gd php-mysql php-curl php-mbstring php-intl php-gmp php-bcmath php-imagick php-xml php-zip mysql-server python3-certbot-apache software-properties-common unzip"
}

variable "git-sha" {
  type    = string
  default = "${env("GITHUB_SHA")}"
}

variable "hcloud_api_token" {
  type      = string
  default   = "${env("HCLOUD_API_TOKEN")}"
  sensitive = true
}

variable "snapshot_name" {
  type = string
  default = "packer-{{timestamp}}"
}

source "hcloud" "autogenerated_1" {
  image       = "${var.hcloud_image}"
  location    = "fsn1"
  server_name = "hcloud-app-builder-${var.app_name}-{{timestamp}}"
  server_type = "cpx11"
  snapshot_labels = {
    git-sha   = "${var.git-sha}"
    version   = "${var.app_version}"
    slug      = "oneclick-${var.app_name}-${var.app_version}-${var.hcloud_image}"
  }
  snapshot_name = "${var.snapshot_name}"
  ssh_username  = "root"
  token         = "${var.hcloud_api_token}"
}

build {
  sources = ["source.hcloud.autogenerated_1"]

  provisioner "shell" {
    inline = ["cloud-init status --wait"]
  }

  provisioner "file" {
    destination = "/etc/"
    source      = "apps/hetzner/nextcloud/files/etc/"
  }

  provisioner "file" {
    destination = "/opt/"
    source      = "apps/hetzner/nextcloud/files/opt/"
  }

  provisioner "file" {
    destination = "/var/"
    source      = "apps/hetzner/nextcloud/files/var/"
  }

  provisioner "file" {
    destination = "/var/www/"
    source      = "apps/shared/www/"
  }

  provisioner "file" {
    destination = "/var/www/html/assets/"
    source      = "apps/hetzner/nextcloud/images/"
  }

  provisioner "shell" {
    environment_vars = ["DEBIAN_FRONTEND=noninteractive", "LC_ALL=C", "LANG=en_US.UTF-8", "LC_CTYPE=en_US.UTF-8"]
    scripts          = ["apps/shared/scripts/apt-upgrade.sh"]
  }

  provisioner "shell" {
    environment_vars = ["DEBIAN_FRONTEND=noninteractive", "LC_ALL=C", "LANG=en_US.UTF-8", "LC_CTYPE=en_US.UTF-8"]
    inline           = ["apt -qqy -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' install ${var.apt_packages}"]
  }

  provisioner "shell" {
    environment_vars = ["application_name=${var.app_name}", "application_version=${var.app_version}", "application_checksum=${var.app_checksum}", "DEBIAN_FRONTEND=noninteractive", "LC_ALL=C", "LANG=en_US.UTF-8", "LC_CTYPE=en_US.UTF-8"]
    scripts          = ["apps/shared/scripts/apt-upgrade.sh", "apps/hetzner/nextcloud/scripts/nextcloud-install.sh", "apps/shared/scripts/cleanup.sh"]
  }

}
