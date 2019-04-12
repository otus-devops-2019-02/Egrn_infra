resource "google_compute_firewall" "firewall_ssh_all" {
  name        = "allow-22-for-all"
  network     = "default"
  target_tags = ["stage-app", "stage-db"]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "firewall_ssh" {
  name        = "allow-22-for-elect"
  network     = "default"
  target_tags = ["prod-app", "prod-db"]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = "${var.ssh_source_ranges}"
}

resource "google_compute_firewall" "firewall_puma" {
  name          = "allow-9292-for-all"
  network       = "default"
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["prod-app", "stage-app"]

  allow {
    protocol = "tcp"
    ports    = ["9292"]
  }
}
