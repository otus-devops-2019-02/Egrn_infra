resource "google_compute_instance" "insts" {
  count        = 1
  name         = "${var.name_db}-${count.index + 1}"
  machine_type = "g1-small"
  zone         = "${var.zone}"
  tags         = ["${var.name_db}"]

  boot_disk {
    initialize_params {
      image = "${var.disk_image_db}"
    }
  }

  network_interface {
    network       = "default"
    access_config = {}
  }

  metadata {
    ssh-keys = "appuser:${file(var.public_key_path)}"
  }
}

/*
resource "null_resource" "db_provision" {
  count = "${var.db_count}"

  triggers {
    need = "${var.provision_need}"

    #need = "${null_resource.app_provision_need.*.id}"
    #filename = "test-${uuid()}"
    #insts_ids = "${join(",", google_compute_instance.insts.*.instance_id)}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo sed 's/bindIp: 127.0.0.1/bindIp: 0.0.0.0/g' -i /etc/mongod.conf",
      "sudo service mongod restart",
    ]

    connection {
      host        = "${element(google_compute_instance.insts.*.network_interface.0.access_config.0.nat_ip,count.index)}"
      type        = "ssh"
      user        = "appuser"
      agent       = false
      private_key = "${file(var.private_key_path)}"
    }
  }

  	  
    #provisioner "local-exec" {
    ##interpreter = ["bash"]
    #command = "echo DATABASE_URL=${google_compute_instance.insts.network_interface.0.access_config.0.nat_ip} > ${path.module}/files/.env"
  	#}
	
}
*/