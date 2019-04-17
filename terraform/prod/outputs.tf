output "ip-app" {
  value = "${module.app.instance_ip}"
}

output "ip-db-int" {
  value = "${module.db.instance_ip_int}"
}

output "ip-db-ext" {
  value = "${module.db.instance_ip_ext}"
}
