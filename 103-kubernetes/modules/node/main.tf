variable "dynamic_ip" {}
variable "enable_ipv6" {}
variable "image" {}
variable "private_key" {}
variable "k8s_nodes" {}
variable "k8s_master" {}
variable "type" {}
variable "security_group" {}
variable "k8s_token" {}

resource "scaleway_server" "node" {
  count               = "${var.k8s_nodes}"
  name                = "k8s-node-${count.index + 1}"
  image               = "${var.image}"
  type                = "${var.type}"
  enable_ipv6         = "${var.enable_ipv6}"
  dynamic_ip_required = "${var.dynamic_ip}"

  tags = [
    "k8s",
    "node",
  ]

  connection {
    type        = "ssh"
    user        = "root"
    private_key = "${file("${path.root}/${var.private_key}")}"
  }

  security_group = "${var.security_group}"

  provisioner "file" {
    source      = "${path.root}/scripts/k8s.sh"
    destination = "/tmp/k8s.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/k8s.sh && /tmp/k8s.sh",
      "kubeadm join --token ${var.k8s_token} ${var.k8s_master}",
      "docker swarm init --advertise-addr ${self.private_ip} --listen-addr ${self.private_ip}",
      "apt-get install ufw",
      "ufw allow 22/tcp",
      "ufw allow 6783/tcp",
      "ufw allow 6783:6784/udp",
      "ufw allow 30000:3500/tcp",
      "ufw allow 80/tcp",
      "ufw allow 443/tcp",
      "ufw allow 8080/tcp",
      "ufw allow 8443/tcp",
      "echo 'y' | ufw enable",
      "systemctl restart docker",
    ]
  }
}

output "public_ip" {
  value = "${scaleway_server.node.public_ip}"
}

output "private_ip" {
  value = "${scaleway_server.node.private_ip}"
}
