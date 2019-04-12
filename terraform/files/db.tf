resource "google_compute_instance" "db" {
  count        = 1
  name         = "reddit-db-${count.index + 1}"
  machine_type = "g1-small"
  zone         = "${var.zone}"
  tags         = ["reddit-app"]

  boot_disk {
    initialize_params {
      image = "${var.disk_image_db}"
    }
  }

  network_interface {
    network       = "default"
    access_config = {}        # использовать ephemeral IP для доступа из Интернет
  }

  metadata {
    ssh-keys = "appuser:${file(var.public_key_path)}"
  }
}
