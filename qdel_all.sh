#!/usr/bin/env bash
qstat -u lpan | awk '{ if ($8 == "R" || $8 == "Q") print "qdel "$1;}'|sh
