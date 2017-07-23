output "public_ip" {
  value = "${scaleway_server.jump_host.public_ip}"
}

output "private_ip" {
  value = "${scaleway_server.jump_host.private_ip}"
}
