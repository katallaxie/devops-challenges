variable "k8s_masters" {}
variable "dynamic_ip" {}
variable "enable_ipv6" {}
variable "private_key" {}
variable "image" {}
variable "type" {}
variable "security_group" {}
variable "k8s_token" {}

resource "scaleway_ip" "k8s-master_ip" {
  server = "${scaleway_server.k8s-master.id}"
}

resource "scaleway_server" "k8s-master" {
  count = "${var.k8s_masters}"
  name  = "k8s-master-${count.index + 1}"
  image = "${var.image}"
  type  = "${var.type}"

  enable_ipv6         = "${var.enable_ipv6}"
  security_group      = "${var.security_group_id}"
  dynamic_ip_required = "${var.dynamic_ip}"

  tags = [
    "k8",
    "master",
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
      "kubeadm init --token ${var.k8s_token} --api-advertise-addresses ${self.private_ip}",
      "kubectl apply -f https://git.io/weave-kube",
      "kubectl create -f https://rawgit.com/kubernetes/dashboard/master/src/deploy/kubernetes-dashboard.yaml",
      "apt-get install ufw",
      "ufw allow 22/tcp",
      "ufw allow 6783/tcp",
      "ufw allow 6783:6784/udp",
      "echo 'n' | ufw enable",
      "systemctl restart docker",
    ]
  }
}

output "public_ip" {
  value = "${scaleway_server.k8s-master.public_ip}"
}

output "private_ip" {
  value = "${scaleway_server.k8s-master.private_ip}"
}
