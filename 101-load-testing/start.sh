#!/bin/bash
docker run --rm -v $PWD/conf:/opt/gatling/conf \
  -v $PWD/simulations:/opt/gatling/user-files/simulations \
  -v $PWD/results:/opt/gatling/results \
  --network 101loadtesting_testing \
  --link db denvazh/gatling:2.2.3 \
  -s example.BaselineSimulation
