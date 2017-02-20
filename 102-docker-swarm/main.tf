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

module "manager" {
  source = "./modules/manager"

  security_group = "${module.security_group.id}"

  type           = "${var.type}"
  image          = "${data.scaleway_image.docker.id}"
  swarm_managers = "${var.swarm_managers}"
  enable_ipv6    = "${var.enable_ipv6}"
  dynamic_ip     = "${var.dynamic_ip}"

  private_key = "${var.private_key}"
}

module "worker" {
  source = "./modules/worker"

  security_group = "${module.security_group.id}"

  type          = "${var.type}"
  image         = "${data.scaleway_image.docker.id}"
  swarm_workers = "${var.swarm_workers}"
  enable_ipv6   = "${var.enable_ipv6}"
  dynamic_ip    = "${var.dynamic_ip}"

  private_key   = "${var.private_key}"
  swarm_manager = "${module.manager.private_ip}"
}

resource "null_resource" "configure-network" {
  connection {
    type        = "ssh"
    user        = "root"
    host        = "${module.manager.public_ip}"
    private_key = "${file("${path.root}/${var.private_key}")}"
  }

  provisioner "remote-exec" {
    inline = [
      "docker network create --driver overlay proxy",
    ]
  }
}

resource "null_resource" "configure-proxy" {
  connection {
    type        = "ssh"
    user        = "root"
    host        = "${module.worker.public_ip}"
    private_key = "${file("${path.root}/${var.private_key}")}"
  }

  provisioner "remote-exec" {
    inline = [
      "docker service create --name proxy -p 80:80 -p 443:443 -p 8080:8080 --network proxy -e MODE=swarm vfarcic/docker-flow-proxy",
    ]
  }
}
