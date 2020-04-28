#!/usr/bin/env bash

# ---------------------------------------------------------
# This script calls a python script to clean up lustre disk.
# Run this script continuously on the Pleiades head node.
# Assumptions:
# * "lustre_disk_cleanup.py" is in path
# ---------------------------------------------------------
# input settings
WORKER_DIR="/nobackupp12/lpan/worker/workdir/"
THRESHOLD=10.0
#
# check lustre disk quota usage and cleanup if necessary
# the tool for lustre disk cleanup
LUSTRE_DISK_CLEANUP_PY=$( which "lustre_disk_cleanup.py" )
if [ ${?} -ne 0 ]; then
    echo "# lustre_disk_cleanup.py not in path" 1>&2
    break
fi

# check if lustre disk cleanup tool file exists
if [ ! -f "${LUSTRE_DISK_CLEANUP_PY}" ]; then
    echo "No file ${LUSTRE_DISK_CLEANUP_PY} found." 1>&2
    exit 1
fi

${LUSTRE_DISK_CLEANUP_PY} --work_dir=${WORKER_DIR} --threshold=${THRESHOLD} &

LUSTRE_DISK_CLEANUP_PID=$!

function kill_lustre_cleanup() {
  echo "Caught SIGTERM signal. Killing $LUSTRE_DISK_CLEANUP_PID ..."
  if kill -0 $LUSTRE_DISK_CLEANUP_PID
  then
    kill -TERM "$LUSTRE_DISK_CLEANUP_PID"
  fi
}
trap kill_lustre_cleanup SIGTERM
trap kill_lustre_cleanup EXIT

