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

resource "null_resource" "configure_proxy" {
  connection {
    type        = "ssh"
    user        = "root"
    host        = "${module.manager.public_ip}"
    private_key = "${file("${path.root}/${var.private_key}")}"
  }

  provisioner "remote-exec" {
    inline = [
      "docker network create --driver overlay --opt encrypted proxy",
      "docker service create --name swarm-listener --network proxy --mount 'type=bind,source=/var/run/docker.sock,target=/var/run/docker.sock' -e DF_NOTIFY_CREATE_SERVICE_URL=http://proxy:8080/v1/docker-flow-proxy/reconfigure -e DF_NOTIFY_REMOVE_SERVICE_URL=http://proxy:8080/v1/docker-flow-proxy/remove --constraint 'node.role==manager' vfarcic/docker-flow-swarm-listener",
      "docker service create --name proxy -p 80:80 -p 443:443 --network proxy -e MODE=swarm -e LISTENER_ADDRESS=swarm-listener vfarcic/docker-flow-proxy",
      "docker service scale prox ${vars.swarm_workers}",
    ]
  }
}
