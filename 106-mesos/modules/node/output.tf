output "public_ips" {
  value = ["${scaleway_server.node.*.public_ip}"]
}

output "private_ips" {
  value = ["${scaleway_server.node.*.private_ip}"]
}
