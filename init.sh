#!/bin/bash

# Init Grafana and preconfigure data source to be influxdb
/run.sh &

sleep 15

curl -v -H "Content-Type: application/json" -X POST \
    --data '{"name": "myinfluxdb", "type": "influxdb", "access": "proxy", "url": "http://influxdb:8086", "database": "k6", "isDefault": true}' \
    http://admin:admin@localhost:3000/api/datasources

grafana_host="http://localhost:3000"
grafana_cred="admin:admin"
grafana_datasource="myinfluxdb"
dashboard=2587
j=$(curl -s -k -u "$grafana_cred" $grafana_host/api/gnet/dashboards/$dashboard | jq .json)
curl -s -k -u "$grafana_cred" -XPOST -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    -d "{\"dashboard\":$j,\"overwrite\":true, \
        \"inputs\":[{\"name\":\"DS_K6\",\"type\":\"datasource\", \
        \"pluginId\":\"influxdb\",\"value\":\"$grafana_datasource\"}]}" \
    $grafana_host/api/dashboards/import; echo ""

kill -SIGINT %%
