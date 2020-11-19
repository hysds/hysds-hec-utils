#!/usr/bin/env bash

MAX_WORKERS=$1

nohup ./pbs_auto_scale_up.sh s2037 $MAX_WORKERS > pbs_auto_scale_up-s2037.log 2>&1 &
nohup ./pbs_auto_scale_up.sh s2252 $MAX_WORKERS > pbs_auto_scale_up-s2252.log 2>&1 &
nohup ./pbs_auto_scale_up.sh s2310 $MAX_WORKERS > pbs_auto_scale_up-s2310.log 2>&1 &
