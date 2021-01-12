#!/bin/bash
LOGFILE="log_auto_scaling_s2037.log"
LAUNCH="sh pbs_auto_scale_up.sh s2037 140"
### LAUNCH="sh count.sh"

trap 'cleanup' SIGTERM
trap 'cleanup' EXIT

function cleanup() {
  echo "Caught SIGTERM signal. Killing $PID ..."
  if kill -0 $PID
  then
    kill -TERM "$PID"
  fi
}

PID=""
CHECK=""
echo "" > "${LOGFILE}"

while :
do
    if [ -n "${PID}" ]; then
        CHECK=`ps -o pid:1= -p "${PID}"`
    fi

    # If PID does not exist anymore, launch again
    if [ -z "${CHECK}" ]; then
        echo "New launch at `date`" >> "${LOGFILE}"

        # Launch command and keep track of the PID
        ${LAUNCH} >> "${LOGFILE}" 2>&1 &
        PID=$!
        echo "launched child process PID: $PID"
    fi

    sleep 5
done

