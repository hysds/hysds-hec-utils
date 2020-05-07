#!/usr/bin/env bash
# pbs init stuff
export PBS_JOBID=$1
WORKER_ID="pleiades_worker.${PBS_JOBID}"
TOKENS=$(date +"%Y %m %d")
IFS=" " read YEAR MONTH DAY <<< ${TOKENS}
TIMESTAMP=$(date +%Y%m%dT%H%M%S)
### export HYSDS_CELERY_CFG="/home1/lpan/verdi/ops/hysds/e_celeryconfig.py"
### export HYSDS_CELERY_CFG_MODULE="e_celeryconfig"
export HYSDS_CELERY_CFG="/home1/lpan/verdi/ops/hysds/mamba_celeryconfig.py"
export HYSDS_CELERY_CFG_MODULE="mamba_celeryconfig"
export NOBACKUP="/nobackupp12/lpan"
### export HYSDS_DATASETS_CFG="/home1/lpan/verdi/etc/e_cluster_config/datasets.json"
export HYSDS_DATASETS_CFG="/home1/lpan/verdi/etc/mamba_config/datasets.json"
#
### export HYSDS_ROOT_CACHE_DIR="${TMPDIR}/"
### echo "TMPDIR=${TMPDIR}"
### echo $(df -h ${TMPDIR})
#
# the top-level worker directory for each job worker
WORKER_DIR="${NOBACKUP}/worker/$YEAR/$MONTH/$DAY/$TIMESTAMP-$WORKER_ID/"
HYSDS_ROOT_WORK_DIR="${WORKER_DIR}/work/"
mkdir -p ${HYSDS_ROOT_WORK_DIR}
HYSDS_ROOT_CACHE_DIR="${WORKER_DIR}/cache/"
mkdir -p ${HYSDS_ROOT_CACHE_DIR}
LOGFILE="${WORKER_DIR}/$TIMESTAMP-$WORKER_ID.log"
cd $HYSDS_ROOT_WORK_DIR
# ensure that job gets all 28 Broadwell cores
export OMP_NUM_THREADS=28
env > $LOGFILE
# run celery job worker & # in background, but save its PID
celery worker --app=hysds --concurrency=1 --loglevel=INFO -Q standard_product-s1gunw-topsapp-pleiades -n $WORKER_ID -O fair --without-mingle --without-gossip --heartbeat-interval=60 >> $LOGFILE 2>&1 &
#
CELERY_JOB_WORKER_PID=$!

function cleanup() {
  echo "Caught SIGTERM signal. Killing $CELERY_JOB_WORKER_PID ..."
  if kill -0 $CELERY_JOB_WORKER_PID
  then
    kill -TERM "$CELERY_JOB_WORKER_PID"
  fi

  ### echo "TMPDIR=${TMPDIR}"
  ### echo $(df -h ${TMPDIR})

  # clean up after the pbs job is done
  rm -rf "$WORKER_DIR"
}
trap cleanup SIGTERM
trap cleanup EXIT

echo "WORKER_DIR: $WORKER_DIR"
echo "CELERY_JOB_WORKER_PID: $CELERY_JOB_WORKER_PID"
python /home1/lpan/verdi/ops/hysds/scripts/harikiri_pid.py  $HYSDS_ROOT_WORK_DIR -i 300 -c 120 -p $CELERY_JOB_WORKER_PID -l https://tpfe2.nas.nasa.gov:8443/mozart/api/v0.1/


