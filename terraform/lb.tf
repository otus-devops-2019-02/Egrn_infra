resource "google_compute_target_pool" "reddit-app-pool" {
  name   = "reddit-app-pool"
  region = "${var.region}"

  instances = ["${var.zone}/reddit-app-0", "${var.zone}/reddit-app-1"]

  health_checks = [
    "${google_compute_http_health_check.reddit-app-healthcheck.name}",
  ]
}

resource "google_compute_forwarding_rule" "reddit-app-forwarding-rule" {
  name       = "reddit-app-forwarding-rule"
  target     = "${google_compute_target_pool.reddit-app-pool.self_link}"
  port_range = "9292"
}

resource "google_compute_http_health_check" "reddit-app-healthcheck" {
  name               = "reddit-app-healthcheck"
  check_interval_sec = 3
  timeout_sec        = 3
  request_path       = "/"
  port               = "9292"
}
