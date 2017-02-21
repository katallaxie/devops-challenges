# Challenge 102 - Docker Swarm

> this is work in progress, there is a sample test provided

## Challenge

> we are going to built the [Docker Swarm](https://www.docker.com/products/docker-swarm) on [Scaleway](https://www.scaleway.com).

What we want to do in this challenge is, to built a production-ready Docker Swarm. Which means, we want to have everything secured and ready to roll-out services.

* [Docker Swarm](https://www.docker.com/products/docker-swarm)
* [Terraform](terraform.io)
* [Scaleway](https://www.scaleway.com)
* [Docker Flow Proxy](https://github.com/vfarcic/docker-flow-proxy)

> we need the private key `scaleway_rsa` you use in Scaleway

## Setup

> most thing can be configured in `main.vars.tf`

> on OSX you can do a `brew install terraform` to install [Terraform](terraform.io)

```
# get all modules
terraform get

# plan the deployment
terraform plan

# apply to Scaleway
terraform apply
```

> `proxy` is the Docker network of where the HAProxy runs

> `ssh` into `docker-manager-1` for configuration of the swarm

See [Docker Flow Proxy](https://github.com/vfarcic/docker-flow-proxy) for further configuration of services and the proxy.

## Notes

* You can change the `scaleway_rsa` private key in `main.vars.tf` 
* You need to configure the Scaleway API access 

```
export SCALEWAY_ORGANIZATION=${YOUR ACCESS KEY}
export SCALEWAY_TOKEN=${YOU API TOKEN}
```

* Region is set in `main.vars.tf` 