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
      "chmod og-rwx /tmp/${var.private_key}",
      "ssh-keyscan ${var.swarm_manager} > ~/.ssh/known_hosts",
      "docker swarm join --token $(ssh -i /tmp/${var.private_key} root@${var.swarm_manager} 'docker swarm join-token -q worker') ${var.swarm_manager}:2377",
      "curl -fsSL https://raw.githubusercontent.com/CWSpear/local-persist/master/scripts/install.sh | sudo bash",
      "rm /tmp/${var.private_key}",
      "mkdir -p /mnt/sync",
      "apt-get -y install ufw",
      "ufw allow 22/tcp",
      "ufw allow from 10.0.0.0/8 to any port 2376 proto tcp",
      "ufw allow from 10.0.0.0/8 to any port 2377 proto tcp",
      "ufw allow from 10.0.0.0/8 to any port 7946 proto tcp",
      "ufw allow from 10.0.0.0/8 to any port 7946 proto udp",
      "ufw allow from 10.0.0.0/8 to any port 4789 proto udp",
      "ufw allow 80/tcp",
      "ufw allow 442/tcp",
      "ufw allow to any from any proto esp",
      "echo 'y' | ufw enable",
      "systemctl restart docker",
    ]
  }

  provisioner "file" {
    content     = "${data.template_file.sync_config.rendered}"
    destination = "/mnt/sync/sync.conf"
  }

}

output "public_ip" {
  value = "${scaleway_server.worker.public_ip}"
}

output "private_ip" {
  value = "${scaleway_server.worker.private_ip}"
}
