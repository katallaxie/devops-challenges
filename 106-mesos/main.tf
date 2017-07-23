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

module "jump_host" {
  source          = "./modules/jump_host"

  security_group  = "${module.security_group.id}"

  type            = "${var.type}"
  image           = "${data.scaleway_image.docker.id}"
  enable_ipv6     = "${var.enable_ipv6}"
  dynamic_ip      = "${var.dynamic_ip}"

  private_key     = "${var.private_key}"

  weave_password  = "${var.weave_password}"
}

module "masters" {
  source          = "./modules/master"

  security_group  = "${module.security_group.id}"

  type            = "${var.type}"
  image           = "${data.scaleway_image.docker.id}"
  count           = "${var.mesos_masters}"
  enable_ipv6     = "${var.enable_ipv6}"
  dynamic_ip      = "${var.dynamic_ip}"

  jump_host       = "${module.jump_host.private_ip}"

  private_key     = "${var.private_key}"

  weave_password  = "${var.weave_password}"
  sync_shared_secret = "${var.sync_shared_secret}"
}

