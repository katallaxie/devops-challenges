provider "scaleway" {
  region = "${var.region}"
}

data "scaleway_image" "docker" {
  architecture = "${lookup(var.archs, var.type)}"
  name         = "Docker"
}

module "security_group" {
  source = "./modules/security_group"
}

module "masters" {
  source          = "./modules/node"

  security_group  = "${module.security_group.id}"

  type            = "${var.type}"
  image           = "${data.scaleway_image.docker.id}"
  count           = "${var.mesos_masters}"
  enable_ipv6     = "${var.enable_ipv6}"
  dynamic_ip      = "${var.dynamic_ip}"

  private_key     = "${var.private_key}"

  weave_password  = "${var.weave_password}"
}

module "slaves" {
  source          = "./modules/node"

  security_group  = "${module.security_group.id}"

  type            = "${var.type}"
  image           = "${data.scaleway_image.docker.id}"
  count           = "${var.mesos_slaves}"
  enable_ipv6     = "${var.enable_ipv6}"
  dynamic_ip      = "${var.dynamic_ip}"

  private_key     = "${var.private_key}"

  weave_password  = "${var.weave_password}"
}

resource "null_resource" "zookeeper" {
  count = "${length(module.masters.public_ips)}"

  connection {
    type        = "ssh"
    host        = "${element(module.masters.public_ips, count.index)}"
    user        = "root"
    private_key = "${file("${path.root}/${var.private_key}")}"
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'test' > /root/test"
    ]
  }
}

