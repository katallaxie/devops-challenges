resource "scaleway_ip" "jump_host" {
  server = "${scaleway_server.jump_host.id}"
}

resource "scaleway_server" "jump_host" {
  name  = "swarm-jump"
  image = "${var.image}"
  type  = "${var.type}"

  enable_ipv6         = "${var.enable_ipv6}"
  security_group      = "${var.security_group_id}"
  dynamic_ip_required = true

  tags = [
    "swarm",
    "jump_host",
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
      "docker swarm init --advertise-addr ${self.private_ip} --listen-addr ${self.private_ip}",
      "mkdir -p /etc/traefik/acme",
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
