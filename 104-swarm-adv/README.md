# Challenge 104 - Advanced Docker Swarm

> this is work in progress, there is a sample test provided

> be inspired [here](https://github.com/veggiemonk/awesome-docker)

## Challenge

> we are going to built an advanced [Docker Swarm](https://www.docker.com/products/docker-swarm) on [Scaleway](https://www.scaleway.com).

What we want to do in this challenge is, to built a production-ready Docker Swarm. Which means, we want to have everything secured and ready to roll-out services.

* [Docker Swarm](https://www.docker.com/products/docker-swarm)
* [Terraform](terraform.io)
* [Scaleway](https://www.scaleway.com)
* [Traefik](https://traefik.io/)
* [Portainer](https://github.com/portainer/portainer)
* [Watchtower](https://github.com/v2tec/watchtower)
* [Docker Swarm GUI](https://github.com/JulienBreux/docker-swarm-gui)
* [Resilio](https://www.resilio.com/individuals/)
* [Local Persist Volume Plugin for Docker](https://github.com/CWSpear/local-persist)

> we need the private key `scaleway_rsa` you use in Scaleway

## Setup

> most thing can be configured in `main.vars.tf`

> on OSX you can do a `brew install terraform` to install [Terraform](terraform.io)

```
# generate secret for Resilio Sync in main.vars.tf
docker run resilio/sync --generate-secret 2>/dev/null
```

## Deploy

```
# get all modules
terraform get

# plan the deployment
terraform plan

# apply to Scaleway
terraform apply
```

Visit [http://swarm-manager-1:9000](http://swarm-manager-1:9000) and configure your admin password. [Docker Swarm GUI](https://github.com/JulienBreux/docker-swarm-gui) is running at port `5090` and [Traefik](https://traefik.io/) at port `8080`.

> `proxy` is the Docker network of which Traefik discovers services

> `ssh` into `swarm-manager-1` for configuration of the swarm

See [Traefik](https://traefik.io/) for further configuration of services and the proxy.

## Test

> we use `traefik` as domain, to be configured in `main.vars.tf`

```
curl -H Host:whoami0.traefik http://<Scaleway IP>
```

## Notes

* You can change the `scaleway_rsa` private key in `main.vars.tf` 
* You need to configure the Scaleway API access 

```
export SCALEWAY_ORGANIZATION=${YOUR ACCESS KEY}
export SCALEWAY_TOKEN=${YOU API TOKEN}
```

* Region is set in `main.vars.tf` 