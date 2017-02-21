variable "swarm_managers" {}
variable "dynamic_ip" {}
variable "enable_ipv6" {}
variable "private_key" {}
variable "image" {}
variable "type" {}
variable "security_group" {}

resource "scaleway_ip" "manager_ip" {
  server = "${scaleway_server.manager.id}"
}

resource "scaleway_server" "manager" {
  count = "${var.swarm_managers}"
  name  = "swarm-manager-${count.index + 1}"
  image = "${var.image}"
  type  = "${var.type}"

  enable_ipv6         = "${var.enable_ipv6}"
  security_group      = "${var.security_group_id}"
  dynamic_ip_required = "${var.dynamic_ip}"

  tags = [
    "swarm",
    "manager",
  ]

  connection {
    type        = "ssh"
    user        = "root"
    private_key = "${file("${path.root}/${var.private_key}")}"
  }

  security_group = "${var.security_group}"

  provisioner "remote-exec" {
    inline = [
      "docker swarm init --advertise-addr ${self.private_ip} --listen-addr ${self.private_ip}",
      "apt-get install ufw",
      "ufw allow 22/tcp",
      "ufw allow 2376/tcp",
      "ufw allow 2377/tcp",
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
  value = "${scaleway_server.manager.public_ip}"
}

output "private_ip" {
  value = "${scaleway_server.manager.private_ip}"
}
