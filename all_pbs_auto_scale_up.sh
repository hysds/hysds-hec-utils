#!/usr/bin/env bash

nohup ./pbs_auto_scale_up.sh s2037 140 > pbs_auto_scale_up-s2037.log 2>&1 &
nohup ./pbs_auto_scale_up.sh s2252 140 > pbs_auto_scale_up-s2252.log 2>&1 &
nohup ./pbs_auto_scale_up.sh s2310 140 > pbs_auto_scale_up-s2310.log 2>&1 &
