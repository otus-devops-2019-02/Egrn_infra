terraform {
  required_version = ">=0.11,<0.12"
}

provider "google" {
  version = "2.0.0"
  project = "${var.project}"
  region  = "${var.region}"
}

module "db" {
  source           = "../modules/db"
  name_db          = "${var.name_db}"
  public_key_path  = "${var.public_key_path}"
  private_key_path = "${var.private_key_path}"
  zone             = "${var.zone}"
  disk_image_db    = "${var.disk_image_db}"
  db_count         = "${var.db_count}"
  provision_need   = "${var.provision_need}"
}

module "app" {
  source           = "../modules/app"
  name_app         = "${var.name_app}"
  public_key_path  = "${var.public_key_path}"
  private_key_path = "${var.private_key_path}"
  zone             = "${var.zone}"
  disk_image_app   = "${var.disk_image_app}"
  app_count        = "${var.app_count}"
  provision_need   = "${var.provision_need}"
  db_ip            = "${join(",",module.db.instance_ip)}"
}
