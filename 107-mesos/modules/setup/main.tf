resource "null_resource" "setup" {

 connection {
    type        = "ssh"
    user        = "root"
    host        = "${var.jump_host}"
    private_key = "${file("${path.root}/${var.private_key}")}"
  }

  provisioner "remote-exec" {
    inline = [
      "docker network create --driver overlay --opt encrypted ${var.sync_network}",
      "docker network create --driver overlay --opt encrypted ${var.mesos_network}",
      "docker service create --detach=false --restart-delay 30s --restart-condition on-failure --name watchtower --mode global --mount type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock centurylink/watchtower --cleanup",
      "docker service create --detach=false --restart-delay 30s --restart-condition on-failure --name sync --mode global --network ${var.sync_network} --mount type=bind,source=/data,destination=/mnt/sync resilio/sync",
      "docker service create --container-label mesos=master -d -u root -p 8181:8181 --mount type=bind,src=/data/folders/swarm/exhibitor,dst=/opt/zookeeper/local_configs --constraint 'node.role == manager' --network ${var.mesos_network} --name exhibitor --mode global --restart-condition any pixelmilk/exhibitor:1.5.6-3.4.10",
      "docker service create --container-label mesos=master -d -e MESOS_PORT=5050 -e MESOS_ZK=zk://exhibitor:2181/mesos -e MESOS_QUORUM=1 -e MESOS_REGISTRY=in_memory --constraint 'node.role == manager' --network ${var.mesos_network} --name mesos-master --mode global --restart-condition any pixelmilk/mesos-master:1.3.0-2.0.3",
      "docker service create -d -e MESOS_PORT=5051 -e MESOS_MASTER=zk://exhibitor:2181/mesos -e MESOS_SWITCH_USER=0 -e MESOS_CONTAINERIZERS=docker,mesos -e MESOS_WORK_DIR=/var/tmp/mesos -e MESOS_SYSTEMD_ENABLE_SUPPORT=false --mount type=bind,src=/sys/fs/cgroup,dst=/sys/fs/cgroup --mount type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock --constraint 'node.role == worker' --network ${var.mesos_network} --name mesos-agent --mode global --restart-condition any pixelmilk/mesos-agent:1.3.0-2.0.3",
      "sleep 5s; docker service create -d -p 8080:8080 --constraint 'node.role == worker' --network ${var.mesos_network} --name marathon --mode replicated mesosphere/marathon --master zk://exhibitor:2181/mesos --zk zk://exhibitor:2181/marathon"
    ]
  }
}

