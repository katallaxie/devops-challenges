variable "swarm_ports" {
  default = [2377, 7946, 4789]
}

resource "scaleway_security_group" "swarm" {
  name        = "Default Swarm Security Group"
  description = "Swarm security group"
}

resource "scaleway_security_group_rule" "accept_tcp" {
  security_group = "${scaleway_security_group.swarm.id}"

  action    = "accept"
  direction = "inbound"

  # NOTE this is just a guess - might not work for you.
  ip_range = "10.0.0.0/8"
  protocol = "TCP"
  port     = "${element(var.swarm_ports, count.index)}"
  count    = "${length(var.swarm_ports)}"
}

resource "scaleway_security_group_rule" "accept_udp" {
  security_group = "${scaleway_security_group.swarm.id}"

  action    = "accept"
  direction = "inbound"

  # NOTE this is just a guess - might not work for you.
  ip_range = "10.0.0.0/8"
  protocol = "UDP"
  port     = "${element(var.swarm_ports, count.index)}"
  count    = "${length(var.swarm_ports)}"
}

resource "scaleway_security_group_rule" "drop_tcp" {
  security_group = "${scaleway_security_group.swarm.id}"

  action    = "drop"
  direction = "inbound"

  # NOTE this is just a guess - might not work for you.
  ip_range = "0.0.0.0/0"
  protocol = "TCP"
  port     = "${element(var.swarm_ports, count.index)}"
  count    = "${length(var.swarm_ports)}"

  depends_on = ["scaleway_security_group_rule.accept_tcp"]
}

resource "scaleway_security_group_rule" "drop_udp" {
  security_group = "${scaleway_security_group.swarm.id}"

  action    = "drop"
  direction = "inbound"

  # NOTE this is just a guess - might not work for you.
  ip_range = "0.0.0.0/0"
  protocol = "UDP"
  port     = "${element(var.swarm_ports, count.index)}"
  count    = "${length(var.swarm_ports)}"

  depends_on = ["scaleway_security_group_rule.accept_udp"]
}

output "id" {
  value = "${scaleway_security_group.swarm.id}"
}
