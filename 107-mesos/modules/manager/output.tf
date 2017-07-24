output "public_ips" {
  value = ["${scaleway_server.manager.*.public_ip}"]
}

output "private_ips" {
  value = ["${scaleway_server.manager.*.private_ip}"]
}
