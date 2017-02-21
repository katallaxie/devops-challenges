variable "k8stoken" {}

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

module "master" {
  source = "./modules/master"

  security_group = "${module.security_group.k8s_master}"

  type        = "${var.type}"
  image       = "${data.scaleway_image.docker.id}"
  k8s_masters = "${var.k8s_masters}"
  k8s_token   = "${var.k8stoken}"
  enable_ipv6 = "${var.enable_ipv6}"
  dynamic_ip  = "${var.dynamic_ip}"

  private_key = "${var.private_key}"
}

module "node" {
  source = "./modules/node"

  security_group = "${module.security_group.k8s_node}"

  type        = "${var.type}"
  image       = "${data.scaleway_image.docker.id}"
  k8s_nodes   = "${var.k8s_nodes}"
  k8s_master  = "${module.master.private_ip}"
  k8s_token   = "${var.k8stoken}"
  enable_ipv6 = "${var.enable_ipv6}"
  dynamic_ip  = "${var.dynamic_ip}"

  private_key = "${var.private_key}"
}
