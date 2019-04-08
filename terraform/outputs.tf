output "reddit-app-ip" {
  value = "${google_compute_instance.reddit-app-.*.network_interface.0.access_config.0.nat_ip}"
}

output "reddit-lb-ip" {
  value = "${google_compute_forwarding_rule.reddit-app-forwarding-rule.ip_address}"
}
