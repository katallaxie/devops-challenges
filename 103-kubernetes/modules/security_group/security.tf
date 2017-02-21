resource "scaleway_security_group" "k8s_master" {
  name        = "Default K8s Master Security Group"
  description = "K8s master security group"
}

resource "scaleway_security_group" "k8s_nodes" {
  name        = "Default K8s Node Security Group"
  description = "K8s noe security group"
}

output "k8s_master" {
  value = "${scaleway_security_group.k8s_master.id}"
}

output "k8s_node" {
  value = "${scaleway_security_group.k8s_nodes.id}"
}
