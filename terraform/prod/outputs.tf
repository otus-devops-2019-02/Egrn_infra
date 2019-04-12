output "ip-app" {
  value = "${module.app.instance_ip}"
}

output "ip-db" {
  value = "${module.db.instance_ip}"
}
