resource "google_compute_instance" "insts" {
  count        = "${var.app_count}"
  name         = "${var.name_app}-${count.index + 1}"
  machine_type = "g1-small"
  zone         = "${var.zone}"
  tags         = ["${var.name_app}"]

  boot_disk {
    initialize_params {
      image = "${var.disk_image_app}"
    }
  }

  network_interface {
    network       = "default"
    access_config = {}

    # nat_ip = "${google_compute_address.app_ip.address}"
  }

  metadata {
    ssh-keys = "appuser:${file(var.public_key_path)}"
  }
}

/*
resource "google_compute_project_metadata_item" "default" {
  key   = "ssh-keys"
  #value = "${element(var.users,count.index)}:${replace(file(var.public_key_path),"appuser",element(var.users,count.index))}"
  #value = "${join("\n",formatlist("Hello, %s!",var.users))}"
  value = "${join("",formatlist("%s%s\n",replace(file(var.public_key_path),"appuser\n",""),var.users))}"

}
*/

/*
resource "null_resource" "app_provision" {
  count = "${var.app_count}"

  triggers {
    need = "${var.provision_need}"

    #filename = "test-${uuid()}"
    #insts_ids = "${join(",", google_compute_instance.insts.*.instance_id)}"
  }

  provisioner "remote-exec" {
    script = "${path.module}/files/deploy-inline.sh"

    connection {
      host        = "${element(google_compute_instance.insts.*.network_interface.0.access_config.0.nat_ip,count.index)}"
      type        = "ssh"
      user        = "appuser"
      agent       = false
      private_key = "${file(var.private_key_path)}"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo sed 's/127.0.0.1:27017/${var.db_ip_int}:27017/g' -i /home/appuser/reddit/app.rb",
      "sudo systemctl start puma",
    ]

    connection {
      host        = "${element(google_compute_instance.insts.*.network_interface.0.access_config.0.nat_ip,count.index)}"
      type        = "ssh"
      user        = "appuser"
      agent       = false
      private_key = "${file(var.private_key_path)}"
    }
  }
}
*/

#resource "google_compute_address" "app_ip" {
#  name = "${var.name_app}-static-ip"
#}

