#!/usr/bin/env bash

# ---------------------------------------------------------
# This script calls dynamically scales up PBS jobs based on
# number of jobs in Ready state as returned by execing "rabbitmq_queue.py"
# Run this script continuously on the Pleiades head node.
# Assumptions:
# * "rabbitmq_queue.py" is in path
# * "lustre_disk_cleanup.py" is in path
# * Automatic scale-down is handled by harikiri-pid.py in each PBS worker job.
# * PBS queue name is "hysds"
# TODO: if the rabbitmq queue does not yet exists, create it by having worker connect to it or submitting jobs to it first.
# ---------------------------------------------------------

# ------------------------------------------------------------------------------
# Automatically determines the full canonical path of where this script is
# located--regardless of what path this script is called from. (if available)
# ${BASH_SOURCE} works in both sourcing and execing the bash script.
# ${0} only works for when execing the bash script. ${0}==bash when sourcing.
BASE_PATH=$(dirname "${BASH_SOURCE}")
# convert potentially relative path to the full canonical path
BASE_PATH=$(cd "${BASE_PATH}"; pwd)
# get the name of the script
BASE_NAME=$(basename "${BASH_SOURCE}")
# ------------------------------------------------------------------------------


# ---------------------------------------------------------
# input settings

# rabbitmq endpoint
RABBITMQ_QUEUE="standard_product-s1gunw-topsapp-pleiades"
#RABBITMQ_API_ENDPOINT="https://100.67.33.56:15673"
### RABBITMQ_API_ENDPOINT="https://hfe1.nas.nasa.gov:15673"
# new Alex cluster
### RABBITMQ_API_ENDPOINT="https://hfe1.nas.nasa.gov:15673"
### RABBITMQ_USERNAME="hysdsops"
### RABBITMQ_PASSWD="Y2FkNTllND"
# e-cluster
RABBITMQ_API_ENDPOINT="http://hfe1.nas.nasa.gov:15672"
RABBITMQ_USERNAME="guest"
RABBITMQ_PASSWD="guest"

WORKER_DIR="/nobackupp12/lpan/worker/workdir/"
THRESHOLD=10.0

# the PBS script to qsub to the hysds queue
PBS_SCRIPT="celery.pbs"

# query interval to rabbitmq, in seconds
### INTERVAL=60
INTERVAL=30

# ---------------------------------------------------------
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


# ---------------------------------------------------------

# the tool for rabbitmq query
RABBITMQ_QUEUE_PY=$( which "rabbitmq_queue.py" )
if [ ${?} -ne 0 ]; then
    echo "# rabbitmq_queue.py not in path" 1>&2
    break
fi

# check if rabbitmq tool file exists
if [ ! -f "${RABBITMQ_QUEUE_PY}" ]; then
    echo "No file ${RABBITMQ_QUEUE_PY} found." 1>&2
    exit 1
fi

while true; do
    TIMESTAMP=$(date +%Y%m%dT%H%M%S)
    echo "$(date) checking qstat on hysds queue..."

    # get count of running and queue jobs
    TOKENS=$( qstat -q hysds | awk '{if ($1=="hysds") print $6 " " $7}' )
    if [ ${?} -eq 0 ]; then
        IFS=" " read PBS_RUNNING PBS_QUEUED <<< ${TOKENS}
        echo "# PBS_RUNNING: ${PBS_RUNNING}"
        echo "# PBS_QUEUED: ${PBS_QUEUED}"
    else
        echo "# unable to get count of running and queue jobs" 1>&2
        sleep 5
        break
    fi

    PBS_RUNNING_QUEUED=$((PBS_RUNNING + PBS_QUEUED))
    echo "# PBS_RUNNING_QUEUED: ${PBS_RUNNING_QUEUED}"

    # get count of ready and unacked messages in rabbitmq for the one specific queue
    TOKENS=$( "${RABBITMQ_QUEUE_PY}" --endpoint="${RABBITMQ_API_ENDPOINT}" --username="${RABBITMQ_USERNAME}" --passwd="${RABBITMQ_PASSWD}" --queue="${RABBITMQ_QUEUE}" )
    # rabbitmq_queue.py outputs to stdout: <queue name> <state> <messages_ready> <messages_unacknowledged>
    if [ ${?} -eq 0 ]; then
        IFS=" " read RABBITMQ_QUEUE RABBITMQ_STATE RABBITMQ_READY RABBITMQ_UNACKED <<< ${TOKENS}
        echo "# RABBITMQ_QUEUE: ${RABBITMQ_QUEUE}"
        echo "# RABBITMQ_STATE: ${RABBITMQ_STATE}"
        echo "# RABBITMQ_READY: ${RABBITMQ_READY}"
        echo "# RABBITMQ_UNACKED: ${RABBITMQ_UNACKED}"
    else
        echo "# unable to call '${RABBITMQ_QUEUE_PY}' to get count of ready and unacked messages in rabbitmq for queue" 1>&2
        sleep 5
        break
    fi

    if [ "${PBS_RUNNING_QUEUED}" -lt "$((RABBITMQ_READY+RABBITMQ_UNACKED))" ]; then
        echo "# ---> qsub one more job..."
        qsub -q hysds ${PBS_SCRIPT}
    fi

    echo ""

    sleep ${INTERVAL}
done