defaultEntryPoints = ["http", "https"]

[entryPoints]
  [entryPoints.https]
  address = ":443"
    [entryPoints.https.tls]

  [entryPoints.http]
  address = ":80"
    [entryPoints.http.redirect]
      entryPoint = "https"

[acme]
email = "${email}"
storage = "acme.json"
entryPoint = "https"
onDemand = true
onHostRule = true
## Comment out for production environment!
caServer = "https://acme-staging.api.letsencrypt.org/directory"

[docker]
domain = "${domain}"
endpoint = "unix:///var/run/docker.sock"
watch = true
swarmmode = true
exposedbydefault = false

# [web]
# address = ":8080"
#
# [web.statistics]
#  RecentErrors = 10
