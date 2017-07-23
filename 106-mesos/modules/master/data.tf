data "template_file" "sync_config" {
  template = "${file("${path.root}/files/sync.conf.tpl")}"

  vars {
    shared_secret  = "${var.sync_shared_secret}"
  }
}
