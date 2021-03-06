terraform {
  required_version = ">=0.11,<0.12"
}

provider "google" {
  version = "2.0.0"
  project = "${var.project}"
  region  = "${var.region}"
}

module "vpc" {
  source            = "../modules/vpc"
  ssh_source_ranges = ["${var.ssh_source_ranges}"]
}
