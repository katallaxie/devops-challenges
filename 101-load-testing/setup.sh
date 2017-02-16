#!/bin/bash
curl -i -XPOST http://localhost:8086/query \
  --data-urlencode "q=CREATE DATABASE graphite"
curl -i -u admin:admin -XPOST http://localhost:3000/api/datasources \
 --header "Content-Type: application/json;charset=UTF-8" \
 --data-binary @$PWD/conf/source.json
 curl -i -u admin:admin -XPOST http://localhost:3000/api/dashboards/db \
 --header "Content-Type: application/json;charset=UTF-8" \
 --data-binary @$PWD/conf/dashboard.json
