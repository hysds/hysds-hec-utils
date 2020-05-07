#!/usr/bin/env bash

# -----------------------------------------------------
# This script is used to test if all forward ports are accessible via tunnel
# from Plieades back to HySDS PCM (in AWS).
# Run this script from Pleiades headnode or compute node.
# -----------------------------------------------------

# .ssh/config:
# -----------------------------------------------------
# Hostname  tpfe2.nas.nasa.gov
# # ------ mozart ------
# # mozart: rabbitmq AMQP
# RemoteForward tpfe2.nas.nasa.gov:5672 mozart.mycluster.hysds.io:5672
# # mozart: rabbitmq REST
# RemoteForward tpfe2.nas.nasa.gov:15673 mozart.mycluster.hysds.io:15673
# # mozart: elasticsearch for figaro
# RemoteForward tpfe2.nas.nasa.gov:9200 mozart.mycluster.hysds.io:9200
# # mozart: redis for elasticsearch figaro
# RemoteForward tpfe2.nas.nasa.gov:6379 mozart.mycluster.hysds.io:6379
# # mozart: rest api
# RemoteForward tpfe2.nas.nasa.gov:8443 mozart.mycluster.hysds.io:443
# # ------ datasets ------
# # grq: elasticsearch for tosca
# RemoteForward tpfe2.nas.nasa.gov:29200 datasets.mycluster.hysds.io:9200
# # grq: rest api
# RemoteForward tpfe2.nas.nasa.gov:28878 datasets.mycluster.hysds.io:8878
# # ??? MAY NOT BE NEEDED ??
# # grq: ?????? 
# #RemoteForward tpfe2.nas.nasa.gov:28888 datasets.mycluster.hysds.io:8888
# # grq: tosca ??????
# #RemoteForward tpfe2.nas.nasa.gov:28443 datasets.mycluster.hysds.io:443
# # ------ metrics ------
# # metrics: redis for elasticsearch kibana
# RemoteForward tpfe2.nas.nasa.gov:36379 metrics.mycluster.hysds.io:6379
# # ------ factotum ------
# # email service
# RemoteForward tpfe2.nas.nasa.gov:10025 factotum.mycluster.hysds.io:25
# -----------------------------------------------------

# -----------------------------------------------------
# input settings

TUNNEL_HOSTNAME="tpfe2.nas.nasa.gov"

# -----------------------------------------------------


# ------ Mozart ------

# mozart: rabbitmq AMQP
URL="http://${TUNNEL_HOSTNAME}:5672"
STDOUTERR=$( curl ${URL} 2>&1 )
if [ $? -eq 0 ]; then
    echo "[pass] mozart rabbitmq AMQP"
else
    echo "# [fail] mozart rabbitmq ${URL}" 1>&2
    echo "${STDOUTERR}" 1>&2
fi

# mozart: rabbitmq REST
URL="https://${TUNNEL_HOSTNAME}:15673"
### URL="http://${TUNNEL_HOSTNAME}:15672"
STDOUTERR=$( curl --insecure ${URL} 2>&1 )
if [ $? -eq 0 ]; then
    echo "[pass] mozart rabbitmq REST"
else
    echo "# [fail] mozart rabbitmq ${URL}" 1>&2
    echo "${STDOUTERR}" 1>&2
fi

# mozart: elasticsearch for figaro
URL="http://${TUNNEL_HOSTNAME}:9200"
STDOUTERR=$( curl ${URL} 2>&1 )
if [ $? -eq 0 ]; then
    echo "[pass] mozart elasticsearch for figaro"
else
    echo "# [fail] mozart elasticsearch for figaro ${URL}" 1>&2
    echo "${STDOUTERR}" 1>&2
fi

# mozart: redis for ES figaro
URL="http://${TUNNEL_HOSTNAME}:6379"
### STDOUTERR=$( curl ${URL} 2>&1 )
STDOUTERR=$( wget --server-response --spider ${URL} 2>&1 )
if [ $? -eq 0 ]; then
    echo "[pass] mozart redis for ES figaro"
else
    echo "# [fail] mozart redis for ES figaro ${URL}" 1>&2
    echo "${STDOUTERR}" 1>&2
fi

# mozart: rest api
URL="https://${TUNNEL_HOSTNAME}:8443/mozart/api/v0.1/doc/"
STDOUTERR=$( curl --insecure ${URL} 2>&1 )
if [ $? -eq 0 ]; then
    echo "[pass] mozart rest api"
else
    echo "# [fail] mozart rest api ${URL}" 1>&2
    echo "${STDOUTERR}" 1>&2
fi

# ------ GRQ datasets ------

# grq: elasticsearch for tosca
URL="http://${TUNNEL_HOSTNAME}:29200"
STDOUTERR=$( curl ${URL} 2>&1 )
if [ $? -eq 0 ]; then
    echo "[pass] grq elasticsearch for tosca"
else
    echo "# [fail] grq elasticsearch for tosca ${URL}" 1>&2
    echo "${STDOUTERR}" 1>&2
fi

# grq: rest api
URL="http://${TUNNEL_HOSTNAME}:28878"
STDOUTERR=$( curl ${URL} 2>&1 )
if [ $? -eq 0 ]; then
    echo "[pass] grq http api"
else
    echo "# [fail] grq http api ${URL}" 1>&2
    echo "${STDOUTERR}" 1>&2
fi

# # tosca???
# URL="http://${TUNNEL_HOSTNAME}:28888"
# STDOUTERR=$( curl ${URL} 2>&1 )
# if [ $? -eq 0 ]; then
#     echo "[pass] grq tosca"
# else
#     echo "# [fail] grq tosca ${URL}" 1>&2
#     echo "${STDOUTERR}" 1>&2
# fi

# # grq: tosca
# URL="https://${TUNNEL_HOSTNAME}:28443/search/"
# STDOUTERR=$( curl ${URL} 2>&1 )
# if [ $? -eq 0 ]; then
#     echo "[pass] grq https proxy"
# else
#     echo "# [fail] grq https proxy ${URL}" 1>&2
#     echo "${STDOUTERR}" 1>&2
# fi

# ------ Metrics ------

# metrics: redis for elasticsearch kibana
URL="http://${TUNNEL_HOSTNAME}:36379"
### STDOUTERR=$( curl ${URL} 2>&1 )
STDOUTERR=$( wget --server-response --spider ${URL} 2>&1 )
if [ $? -eq 0 ]; then
    echo "[pass] metrics redis for ES metrics"
else
    echo "# [fail] metrics redis for ES metrics ${URL}" 1>&2
    echo "${STDOUTERR}" 1>&2
fi

# ------ Factotum ------

# factotum: smtp
URL="http://${TUNNEL_HOSTNAME}:10025"
STDOUTERR=$( curl ${URL} 2>&1 )
if [ $? -eq 0 ]; then
    echo "[pass] factotum smtp"
else
    echo "# [fail] factotum smtp ${URL}" 1>&2
    echo "${STDOUTERR}" 1>&2
fi




