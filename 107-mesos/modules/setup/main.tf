resource "null_resource" "setup" {

 connection {
    type        = "ssh"
    user        = "root"
    host        = "${var.jump_host}"
    private_key = "${file("${path.root}/${var.private_key}")}"
  }

  provisioner "remote-exec" {
    inline = [
      "docker service create --container-label mesos=master -d -u root -p 8181:8181 --mount type=bind,src=/data/folders/swarm/exhibitor,dst=/opt/zookeeper/local_configs --constraint 'node.role == manager' --network ${var.mesos_network} --name exhibitor --mode global --restart-condition any pixelmilk/exhibitor:1.5.6-3.4.10",
      "docker service create --container-label mesos=master -d -e MESOS_PORT=5050 -e MESOS_ZK=zk://exhibitor:2181/mesos -e MESOS_QUORUM=1 -e MESOS_REGISTRY=in_memory --constraint 'node.role == manager' --network ${var.mesos_network} --name mesos-master --mode global --restart-condition any pixelmilk/mesos-master:1.3.0-2.0.3"
    ]
  }
}

