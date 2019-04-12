output "allowed-source-for-ssh" {
  value = "${module.vpc.src-ssh}"
}

output "allowed-source-for-puma" {
  value = "${module.vpc.src-puma}"
}
