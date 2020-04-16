#!/usr/bin/env bash
# pbs init stuff
export PBS_JOBID=$1
WORKER_ID="pleiades_worker.${PBS_JOBID}"
TOKENS=$(date +"%Y %m %d")
IFS=" " read YEAR MONTH DAY <<< ${TOKENS}
TIMESTAMP=$(date +%Y%m%dT%H%M%S)
export NOBACKUP="/nobackupp12/lpan"
export HYSDS_ROOT_WORK_DIR="$NOBACKUP/worker/workdir/$YEAR/$MONTH/$DAY/$TIMESTAMP-$WORKER_ID/"
mkdir -p $HYSDS_ROOT_WORK_DIR
export HYSDS_DATASETS_CFG="/home1/lpan/verdi/etc/datasets.json"
mkdir -p $NOBACKUP/worker/logs/$YEAR/$MONTH/$DAY/
LOGFILE="$NOBACKUP/worker/logs/$YEAR/$MONTH/$DAY/$TIMESTAMP-$WORKER_ID.log"
cd $HYSDS_ROOT_WORK_DIR
export OMP_NUM_THREADS=28
env > $LOGFILE
# run celery job worker & # in background, but save its PID
celery worker --app=hysds --concurrency=1 --loglevel=INFO -Q standard_product-s1gunw-topsapp-pleiades -n $WORKER_ID -O fair --without-mingle --without-gossip --heartbeat-interval=60 >> $LOGFILE 2>&1 &
#
CELERY_JOB_WORKER_PID=$!

function kill_celery_worker() {
  echo "Caught SIGTERM signal. Killing $CELERY_JOB_WORKER_PID ..." 
  if kill -0 $CELERY_JOB_WORKER_PID
  then
    kill -TERM "$CELERY_JOB_WORKER_PID"
  fi
}
trap kill_celery_worker SIGTERM
trap kill_celery_worker EXIT

echo "HYSDS_ROOT_WORK_DIR: $HYSDS_ROOT_WORK_DIR"
echo "CELERY_JOB_WORKER_PID: $CELERY_JOB_WORKER_PID"
python /home1/lpan/github/hysds/scripts/harikiri_pid.py  $HYSDS_ROOT_WORK_DIR -i 300 -c 60 -p $CELERY_JOB_WORKER_PID -l https://hfe1.nas.nasa.gov:8443/mozart/api/v0.1/

