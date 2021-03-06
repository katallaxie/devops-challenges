variable "dynamic_ip" {}
variable "enable_ipv6" {}
variable "image" {}
variable "private_key" {}
variable "swarm_workers" {}
variable "swarm_manager" {}
variable "type" {}
variable "security_group" {}

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
      "docker swarm join --token $(ssh -i /tmp/scaleway_rsa root@${var.swarm_manager} 'docker swarm join-token -q worker') ${var.swarm_manager}:2377",
      "rm /tmp/${var.private_key}",
      "apt-get install ufw",
      "ufw allow 22/tcp",
      "ufw allow 2376/tcp",
      "ufw allow 7946/tcp",
      "ufw allow 7946/udp",
      "ufw allow 4789/udp",
      "ufw allow 80/tcp",
      "ufw allow 443/tcp",
      "echo 'y' | ufw enable",
      "systemctl restart docker",
    ]
  }
}

output "public_ip" {
  value = "${scaleway_server.worker.public_ip}"
}

output "private_ip" {
  value = "${scaleway_server.worker.private_ip}"
}
