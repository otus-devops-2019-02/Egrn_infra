output "src-ssh" {
  value = "${google_compute_firewall.firewall_ssh.source_ranges}"
}

output "src-puma" {
  value = "${google_compute_firewall.firewall_puma.source_ranges}"
}
