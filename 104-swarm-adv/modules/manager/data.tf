data "template_file" "traefik_config" {
  template = "${file("${path.root}/files/traefik.toml.tpl")}"

  vars {
    email       = "${var.traefik_email}"
    domain      = "${var.traefik_domain}"
  }
}

data "template_file" "sync_config" {
  template = "${file("${path.root}/files/sync.conf.tpl")}"

  vars {
    shared_secret  = "${var.sync_shared_secret}"
  }
}
