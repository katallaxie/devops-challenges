variable "swarm_managers" {}
variable "dynamic_ip" {}
variable "enable_ipv6" {}
variable "private_key" {}
variable "image" {}
variable "type" {}
variable "security_group" {}
variable "swarm_network" {}
variable "sync_network" {}
variable "traefik_email" {}
variable "traefik_domain" {}
variable "sync_shared_secret" {}
variable "monitor_network" {}

data "template_file" "sync_config" {
  template = "${file("${path.root}/files/sync.conf.tpl")}"

  vars {
    shared_secret  = "${var.sync_shared_secret}"
  }
}

resource "scaleway_ip" "manager" {
  server = "${scaleway_server.manager.id}"
}

data "template_file" "traefik_config" {
  template = "${file("${path.root}/files/traefik.toml.tpl")}"

  vars {
    email       = "${var.traefik_email}"
    domain      = "${var.traefik_domain}"
  }
}

resource "scaleway_server" "manager" {
  count = "${var.swarm_managers}"
  name  = "swarm-manager-${count.index + 1}"
  image = "${var.image}"
  type  = "${var.type}"

  enable_ipv6         = "${var.enable_ipv6}"
  security_group      = "${var.security_group_id}"
  dynamic_ip_required = true

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

  provisioner "remote-exec" {
    inline = [
      "curl -fsSL https://raw.githubusercontent.com/CWSpear/local-persist/master/scripts/install.sh | sudo bash",
      "shutdown -r now"
    ]
  }

  provisioner "file" {
    content     = "${data.template_file.sync_config.rendered}"
    destination = "/data/sync.conf"
  }

  provisioner "remote-exec" {
    inline = [
      "docker network create --driver overlay --opt encrypted ${var.sync_network}",
      "docker network create --driver overlay --opt encrypted ${var.swarm_network}",
      "docker network create --driver overlay --opt encrypted ${var.monitor_network}",
      "docker service create --detach=false --restart-delay 30s --restart-condition on-failure --name watchtower --mode global --mount type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock centurylink/watchtower --cleanup",
      "docker service create --detach=false --restart-delay 30s --restart-condition on-failure --name sync --mode global --network ${var.sync_network} --mount type=bind,source=/data,destination=/mnt/sync resilio/sync",
      "mkdir -p /data/folders/swarm/portainer",
      "mkdir -p /data/folders/swarm/influx",
      "mkdir -p /data/folders/swarm/grafana",
      "touch /data/folders/swarm/acme.json",
      "chmod 0600 /data/folders/swarm/acme.json",
      "docker volume create --name portainer --driver local-persist -o mountpoint=/data/folders/swarm/portainer",
      "docker volume create --name influx --driver local-persist -o mountpoint=/data/folders/swarm/influx",
      "docker volume create --name grafana --driver local-persist -o mountpoint=/data/folders/swarm/grafana",
    ]
  }

  provisioner "file" {
    content     = "${data.template_file.traefik_config.rendered}"
    destination = "/data/folders/swarm/traefik.toml"
  }

  provisioner "remote-exec" {
    inline = [
      "docker service create --detach=false --publish 9000:9000 --label traefik.port=9000 --label traefik.enable=true --label traefik.backend=portainer --restart-delay 30s --restart-condition on-failure --constraint 'node.role == manager' --name portainer --mode replicated --replicas 1 --network ${var.swarm_network} --mount type=volume,src=portainer,dst=/data --mount type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock portainer/portainer -H unix:///var/run/docker.sock",
      "docker service create --detach=false --publish 80:80 --publish 443:443 --restart-delay 30s --restart-condition on-failure --constraint 'node.role == manager' --network ${var.swarm_network} --name traefik --mode global --mount type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock --mount type=bind,src=/data/folders/swarm/acme.json,dst=/acme.json --mount type=bind,src=/data/folders/swarm/traefik.toml,dst=/etc/traefik/traefik.toml traefik:1.3.0",
      "docker service create --detach=false --network ${var.monitor_network}  --replicas 1 --restart-delay 30s --restart-condition on-failure --constraint 'node.role == manager' --name influx --mount type=volume,src=influx,dst=/var/lib/influxdb --mount type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock influxdb",
      "docker exec `docker ps | grep -i influx | awk '{print $1}'` influx -execute 'CREATE DATABASE cadvisor'",
      "docker service create --detach=false --hostname '{{.Node.ID}}' --network ${var.monitor_network} --name cadvisor --restart-delay 30s --restart-condition on-failure --mode global --mount type=bind,source=/var/run,target=/var/run,readonly=false --mount type=bind,source=/,target=/rootfs,readonly=true --mount type=bind,source=/sys,target=/sys,readonly=true --mount type=bind,source=/var/lib/docker,target=/var/lib/docker,readonly=true  google/cadvisor:canary -logtostderr -docker_only -storage_driver=influxdb -storage_driver_db=cadvisor -storage_driver_host=influx:8086",
      "docker service create --detach=false --label traefik.port=3000 --label traefik.enable=true --label traefik.backend=grafana --network ${var.monitor_network} --network ${var.swarm_network} --replicas 1 --restart-delay 30s --restart-condition on-failure --constraint 'node.role == manager' --name grafana --mount type=volume,src=grafana,dst=/var/lib/grafana grafana/grafana"
    ]
  }
}

output "public_ip" {
  value = "${scaleway_server.manager.public_ip}"
}

output "private_ip" {
  value = "${scaleway_server.manager.private_ip}"
}
