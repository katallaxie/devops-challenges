variable "dynamic_ip" {}
variable "enable_ipv6" {}
variable "image" {}
variable "private_key" {}
variable "swarm_workers" {}
variable "swarm_manager" {}
variable "type" {}
variable "security_group" {}
variable "sync_shared_secret" {}

data "template_file" "sync_config" {
  template = "${file("${path.root}/files/sync.conf.tpl")}"

  vars {
    shared_secret  = "${var.sync_shared_secret}"
  }
}

resource "scaleway_server" "worker" {
  count               = "${var.swarm_workers}"
  name                = "swarm-worker-${count.index + 1}"
  image               = "${var.image}"
  type                = "${var.type}"
  enable_ipv6         = "${var.enable_ipv6}"
  dynamic_ip_required = "${var.dynamic_ip}"

  tags = [
    "swarm",
    "worker",
  ]

  connection {
    type        = "ssh"
    user        = "root"
    private_key = "${file("${path.root}/${var.private_key}")}"
  }

  security_group = "${var.security_group}"

  provisioner "file" {
    source      = "${path.root}/${var.private_key}"
    destination = "/tmp/${var.private_key}"
  }

  provisioner "remote-exec" {
    inline = [
      "export DEBIAN_FRONTEND=noninteractive",
      "apt-get update",
      "apt-get -y -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' upgrade docker-engine",
      "apt-get -y install iptables-persistent",
      "curl -L https://github.com/docker/compose/releases/download/1.13.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose",
      "chmod +x /usr/local/bin/docker-compose"
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "chmod og-rwx /tmp/${var.private_key}",
      "ssh-keyscan ${var.swarm_manager} > ~/.ssh/known_hosts",
      "docker swarm join --token $(ssh -i /tmp/${var.private_key} root@${var.swarm_manager} 'docker swarm join-token -q worker') ${var.swarm_manager}:2377",
      "rm /tmp/${var.private_key}",
      "mkdir -p /data",
      "systemctl restart docker",
      "systemd-machine-id-setup"
    ]
  }

  provisioner "file" {
    source      = "${path.root}/files/rules.v4"
    destination = "/etc/iptables/rules.v4"
  }

  provisioner "file" {
    source      = "${path.root}/files/rules.v6"
    destination = "/etc/iptables/rules.v6"
  }

  provisioner "file" {
    content     = "${data.template_file.sync_config.rendered}"
    destination = "/data/sync.conf"
  }

  provisioner "remote-exec" {
    inline = [
      "curl -fsSL https://raw.githubusercontent.com/CWSpear/local-persist/master/scripts/install.sh | sudo bash",
      "shutdown -r now"
    ]
  }

}

output "public_ip" {
  value = "${scaleway_server.worker.public_ip}"
}

output "private_ip" {
  value = "${scaleway_server.worker.private_ip}"
}
