resource "google_compute_instance" "app" {
  count        = 1
  name         = "reddit-app-${count.index + 1}"
  machine_type = "g1-small"
  zone         = "${var.zone}"
  tags         = ["reddit-app"]

  boot_disk {
    initialize_params {
      image = "${var.disk_image_app}"
    }
  }

  network_interface {
    network = "default"

    access_config = {
      nat_ip = "${google_compute_address.app_ip.address}"
    }
  }

  metadata {
    ssh-keys = "appuser:${file(var.public_key_path)}"
  }
}

resource "google_compute_address" "app_ip" {
  name = "reddit-app-ip"
}

resource "google_compute_firewall" "firewall_puma" {
  name          = "allow-puma-default"
  network       = "default"
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["reddit-app", "puma-server"]

  allow {
    protocol = "tcp"
    ports    = ["9292"]
  }
}
