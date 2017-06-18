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
  swarm_network  = "${var.swarm_network}"
  enable_ipv6    = "${var.enable_ipv6}"
  dynamic_ip     = "${var.dynamic_ip}"

  private_key        = "${var.private_key}"
  sync_network       = "${var.sync_network}",
  monitor_network    = "${var.monitor_network}",
  traefik_email       = "${var.traefik_email}",
  traefik_domain      = "${var.traefik_domain}",
  sync_shared_secret = "${var.sync_shared_secret}"
  influx_username     = "${var.influx_username}",
  influx_password     = "${var.influx_password}"
}

module "worker" {
  source = "./modules/worker"

  security_group   = "${module.security_group.id}"

  type             = "${var.type}"
  image            = "${data.scaleway_image.docker.id}"
  swarm_workers    = "${var.swarm_workers}"
  enable_ipv6      = "${var.enable_ipv6}"
  dynamic_ip       = "${var.dynamic_ip}"

  private_key      = "${var.private_key}"
  swarm_manager    = "${module.manager.private_ip}"
  sync_shared_secret = "${var.sync_shared_secret}"
}
