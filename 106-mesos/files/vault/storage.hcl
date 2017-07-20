storage "zookeeper" {
  address = "zookeeper:2181"
  path    = "vault/"
  disable_clustering = "true"
  redirect_addr = "http://zookeeper"
}
