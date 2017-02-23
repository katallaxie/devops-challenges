# Challenge 103 - Kubernetes

> this is work in progress, there is a sample test provided

## Challenge

> we are going to built a [Kubernetes Cluster](https://kubernetes.io/) on [Scaleway](https://www.scaleway.com).

What we want to do in this challenge is, to built a somehow production-ready Kubernetes Cluster. Which means, we want to have everything secured and ready to roll-out services.

* [Kubernetes](https://kubernetes.io/)
* [Terraform](terraform.io)
* [Scaleway](https://www.scaleway.com)
* [Weave](https://weave.works)

> we need the private key `scaleway_rsa` you use in Scaleway

## Setup

> most thing can be configured in `main.vars.tf`

> on OSX you can do a `brew install terraform` to install [Terraform](terraform.io)

First we need to create a token to be used to join the nodes to the cluster

```
python -c 'import random; print "%0x.%0x" % (random.SystemRandom().getrandbits(3*8), random.SystemRandom().getrandbits(8*8))'
```

and a password for Weave

```
pwgen -s 32
```

before we can get the confi running.

```
# get all modules
terraform get

# plan the deployment
terraform plan -var "k8stoken=<token> - var "weave_password=<password>"

# apply to Scaleway
terraform apply -var "k8stoken=<token> - var "weave_password=<password>""
```

## Notes

* You can change the `scaleway_rsa` private key in `main.vars.tf` 
* You need to configure the Scaleway API access 

```
export SCALEWAY_ORGANIZATION=${YOUR ACCESS KEY}
export SCALEWAY_TOKEN=${YOU API TOKEN}
```

* Region is set in `main.vars.tf` 

## Install and Launch the Weave Cloud Probes

> `ssh` into `k8s-master-1` to further setup the cluser

From the master

```
kubectl apply -f \
  https://cloud.weave.works/k8s.yaml?t=<cloud-token>
```

The `<cloud-token>` is found in the settings dialog on [Weave Cloud](https://cloud.weave.works/).

If you mistyped or copied and pasted the command incorrectly, you can remove the DaemonSet with:

```
kubectl delete -f https://cloud.weave.works/k8s.yaml?t=anything
```

Return to Weave Cloud, and click **Explore** to display Scope and then **Pods** to show the Kubernetes cluster. Ensure that the **All Namespaces** filter is enabled from the left-hand corner.


## Installing the Sock Shop Demo

To put your cluster through its paces, install the sample microservices application, Socks Shop. Learn more about the sample microservices app by referring to the [microservices-demo README](https://github.com/microservices-demo/microservices-demo).

To install the Sock Shop, run the following:

```
kubectl create namespace sock-shop
git clone https://github.com/microservices-demo/microservices-demo
cd microservices-demo
kubectl apply -n sock-shop -f deploy/kubernetes/manifests
```

Click on the **Pod** view and then enable the **sock-shop** namespace filter from the bottom left-hand corner in the Weave Cloud user interface.

It takes several minutes to download and start all of the containers.  Watch the output of `kubectl get pods -n sock-shop` to see that all of the containers are successfully running.

Or view the containers as they get created in [Weave Cloud](https://cloud.weave.works/).


## Viewing the Sock Shop in Your Browser

Find the port that the cluster allocated for the front-end service by running:

```
kubectl describe svc front-end -n sock-shop
```

The output should look like:

```
Name:                   front-end
Namespace:              sock-shop
Labels:                 name=front-end
Selector:               name=front-end
Type:                   NodePort
IP:                     100.66.88.176
Port:                   <unset> 80/TCP
NodePort:               <unset> 31869/TCP
Endpoints:              <none>
Session Affinity:       None
```

Launch the Sock Shop in your browser by going to the IP address of any of your node machines in your browser, and by specifying the NodePort. So for example, `http://<master_ip>:<pNodePort>`. You can find the IP address of the machines in the Scaleway dashboard.

In the example above, the NodePort is `31869`.

If there is a firewall, make sure it exposes this port to the internet before you try to access it.
