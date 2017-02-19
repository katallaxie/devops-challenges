# Challenge 101 - Load Testing

> this is work in progress, there is a sample test provided

## Challenge

What we want to do in this tutorial is to setup a high-performance, and customizable setup for doing local load tests.
We are going to use the following technologies

* [Docker](https://www.dockercom) + [Docker Compose](Docker Compose)
* [InfluxDB](https://www.influxdata.com/)
* [Grafana](http://grafana.org/)
* [Gatling](http://gatling.io/)

## Setup

> by design there are some multiple steps necessary to setup this project, this is by intention, because we want to use volume dockers for storage and not persist data in the repository

```
1. Start InfluxDB + Grafana
docker-compose up

# you can add -d as to have it running as daemons

2. Configure InfluxDB + Grafana
./setup.sh

3. Start the sample test
./start.sh

# to stop the daemons do a docker-compose down
```

# License
[MIT](/LICENSE)
