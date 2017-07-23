resource "scaleway_server" "jump_host" {
  name  = "jumphost"
  image = "${var.image}"
  type  = "${var.type}"

  enable_ipv6         = "${var.enable_ipv6}"
  security_group      = "${var.security_group_id}"
  dynamic_ip_required = true

  tags = [
    "mesos",
    "jumphost"
  ]

  connection {
    type        = "ssh"
    user        = "root"
    private_key = "${file("${path.root}/${var.private_key}")}"
  }

  security_group = "${var.security_group}"

  provisioner "file" {
    source      = "${path.root}/files/weave.service"
    destination = "/etc/systemd/system/weave.service"
  }

  provisioner "remote-exec" {
    inline = [
      "export DEBIAN_FRONTEND=noninteractive",
      "apt-get update",
      "apt-get -y -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' upgrade docker-engine",
      "apt-get -y install iptables-persistent",
      "curl -L https://github.com/docker/compose/releases/download/1.13.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose",
      "chmod +x /usr/local/bin/docker-compose",
      "curl -L git.io/weave -o /usr/local/bin/weave",
      "chmod a+x /usr/local/bin/weave",
      "echo 'WEAVE_PASSWORD=${var.weave_password}' > /etc/default/weave",
      "echo 'eval $(weave env)' >> ~/.bashrc && . ~/.bashrc",
      "systemctl enable weave",
      "systemctl start weave"
    ]
  }

}

