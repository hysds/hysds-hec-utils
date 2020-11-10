#!/usr/bin/env bash
qstat -u esi_sar | awk '{ if ($8 == "R" || $8 == "Q") print "qdel "$1;}'|sh
