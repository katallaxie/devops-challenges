provider "scaleway" {
  region = "${var.region}"
}

module "security_group" {
  source = "./modules/security_group"
}

module "jump_host" {
  source         = "./modules/jump_host"

  security_group = "${module.security_group.id}"

  type           = "${var.type}"
  image          = "${data.scaleway_image.docker.id}"
  enable_ipv6    = "${var.enable_ipv6}"
  dynamic_ip     = "${var.dynamic_ip}"

  private_key        = "${var.private_key}"
  sync_network       = "${var.sync_network}",
  mesos_network      = "${var.mesos_network}",
  sync_shared_secret = "${var.sync_shared_secret}"
}

module "manager" {
  source = "./modules/manager"

  security_group = "${module.security_group.id}"

  type           = "${var.type}"
  image          = "${data.scaleway_image.docker.id}"
  swarm_managers = "${var.swarm_managers}"
  enable_ipv6    = "${var.enable_ipv6}"
  dynamic_ip     = "${var.dynamic_ip}"
  jump_host      = "${module.jump_host.private_ip}"

  private_key        = "${var.private_key}"
  sync_network       = "${var.sync_network}",
  mesos_network      = "${var.mesos_network}",
  sync_shared_secret = "${var.sync_shared_secret}"
}

module "worker" {
  source = "./modules/worker"

  security_group   = "${module.security_group.id}"

  type             = "${var.type}"
  image            = "${data.scaleway_image.docker.id}"
  swarm_workers    = "${var.swarm_workers}"
  enable_ipv6      = "${var.enable_ipv6}"
  dynamic_ip       = "${var.dynamic_ip}"

  private_key        = "${var.private_key}"
  jump_host          = "${module.jump_host.private_ip}"
  mesos_network      = "${var.mesos_network}",
  sync_shared_secret = "${var.sync_shared_secret}"
}

module "setup" {
  source = "./modules/setup"

  mesos_network      = "${var.mesos_network}",
  private_key        = "${var.private_key}"
  jump_host          = "${module.jump_host.public_ip}"
}
