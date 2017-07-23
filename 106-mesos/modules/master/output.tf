output "public_ips" {
  value = "${join(",", scaleway_server.node.*.public_ip)}"
}

output "private_ips" {
  value = "${join(",", scaleway_server.node.*.public_ip)}"
}
