variable "private_key" {}
variable "weave_network" {}
variable "public_ips" {}
# variable "private_ips" {}

resource "null_resource" "zookeeper" {
  count = "${length(split(",",var.public_ips))}"

  connection {
    type        = "ssh"
    host        = "${element(split(",",var.public_ips), count.index)}"
    user        = "root"
    private_key = "${file("${path.root}/${var.private_key}")}"
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'test' > /root/test"
    ]
  }
}
