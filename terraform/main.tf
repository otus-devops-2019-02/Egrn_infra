terraform {
  # Версия terraform
  required_version = ">=0.11,<0.12"
}

provider "google" {
  # Версия провайдера
  version = "2.0.0"

  # ID проекта
  project = "${var.project}"
  region  = "${var.region}"
}

resource "google_compute_firewall" "firewall_puma" {
  name          = "allow-puma-default"
  network       = "default"                     # Название сети, в которой действует правило
  source_ranges = ["0.0.0.0/0"]                 # Каким адресам разрешаем доступ
  target_tags   = ["reddit-app", "puma-server"] # Правило применимо для инстансов с перечисленными тэгами

  allow {
    protocol = "tcp"    # Какой доступ разрешить
    ports    = ["9292"]
  }
}

#resource "google_compute_project_metadata_item" "default" {
#	count = "${length(var.users)}"
#		key   =	"ssh-keys"
#		value = "${element(var.users,count.index)}:${replace(file(var.public_key_path),"appuser",element(var.users,count.index))}"
#}

resource "google_compute_instance" "reddit-app-" {
  name         = "reddit-app-${count.index}"
  count        = 2
  machine_type = "g1-small"
  zone         = "${var.zone}"
  tags         = ["reddit-app"]

  boot_disk {
    initialize_params {
      image = "${var.disk_image}"
    }
  }

  network_interface {
    network       = "default" # сеть, к которой присоединить данный интерфейс
    access_config = {}        # использовать ephemeral IP для доступа из Интернет
  }

  metadata {
    ssh-keys = "appuser:${file(var.public_key_path)}"
  }

  connection {
    type        = "ssh"
    user        = "appuser"
    agent       = false
    private_key = "${file(var.private_key_path)}" # путь до приватного ключа
  }

  provisioner "file" {
    source      = "files/puma.service"
    destination = "/tmp/puma.service"
  }

  provisioner "remote-exec" {
    script = "files/deploy.sh"
  }
}
