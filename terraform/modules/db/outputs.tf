output "instance_ip_ext" {
  value = "${google_compute_instance.insts.*.network_interface.0.access_config.0.nat_ip}"
}

output "instance_ip_int" {
  value = "${google_compute_instance.insts.*.network_interface.0.network_ip}"
}

