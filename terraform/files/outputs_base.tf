output "ip-app" {
  value = "${google_compute_instance.app.network_interface.0.access_config.0.nat_ip}"
}

output "ip-db" {
  value = "${google_compute_instance.db.network_interface.0.access_config.0.nat_ip}"
}

output "ip-static" {
  value = "${google_compute_address.app_ip.address}"
}
