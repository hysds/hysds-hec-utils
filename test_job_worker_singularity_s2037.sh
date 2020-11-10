#!/usr/bin/env bash
# pbs init stuff
# to get singularity
source /usr/local/lib/global.profile
module use /nasa/modulefiles/testing
module load singularity
### export PBS_JOBID=$1
export PBS_JOBID=2668
WORKER_ID="pleiades_worker.${PBS_JOBID}"
TOKENS=$(date +"%Y %m %d")
IFS=" " read YEAR MONTH DAY <<< ${TOKENS}
TIMESTAMP=$(date +%Y%m%dT%H%M%S)
### export SANDBOX_DIR="/nobackupp12/esi_sar/PGE/container-aria-jpl_ariamh_aria-446_singularity-2020-10-26-78b580995345.simg"
### export SANDBOX_DIR="/nobackupp12/esi_sar/PGE/container-aria-jpl_ariamh_aria-446_singularity-2020-10-27-aa1f68a8113e.simg"
export SANDBOX_DIR="/nobackupp12/esi_sar/PGE/container-aria-jpl_ariamh_aria-446_singularity-2020-10-28-dd5c2be5cbd8.simg"
### export HYSDS_CELERY_CFG="/home4/esi_sar/verdi/ops/hysds/e_celeryconfig.py"
### export HYSDS_CELERY_CFG_MODULE="e_celeryconfig"
export HYSDS_CELERY_CFG="/home4/esi_sar/verdi/ops/hysds/mamba_celeryconfig.py"
export HYSDS_CELERY_CFG_MODULE="mamba_celeryconfig"
### export NOBACKUP="/nobackupp12/esi_sar/s2037"
export NOBACKUP="/nobackupp12/esi_sar/test/s2037"
### export HYSDS_DATASETS_CFG="/home4/esi_sar/verdi/etc/e_cluster_config/datasets.json"
export HYSDS_DATASETS_CFG="/home4/esi_sar/verdi/etc/mamba_config/datasets.json"
#
export VERDI_ROOT="/home4/esi_sar/verdi/"
export DEM_ROOT="/nobackupp12/esi_sar/datasets/"
#
### export HYSDS_ROOT_CACHE_DIR="${TMPDIR}/"
### echo "TMPDIR=${TMPDIR}"
### echo $(df -h ${TMPDIR})
#
# the top-level worker directory for each job worker
WORKER_DIR="${NOBACKUP}/worker/$YEAR/$MONTH/$DAY/$TIMESTAMP-$WORKER_ID"
LOG_DIR="${NOBACKUP}/worker/logs/$YEAR/$MONTH/$DAY/$TIMESTAMP-$WORKER_ID"
export HYSDS_ROOT_WORK_DIR="${WORKER_DIR}/work/"
mkdir -p ${HYSDS_ROOT_WORK_DIR}
export HYSDS_ROOT_CACHE_DIR="${WORKER_DIR}/cache/"
mkdir -p ${HYSDS_ROOT_CACHE_DIR}
mkdir -p ${LOG_DIR}
LOGFILE="${LOG_DIR}/$TIMESTAMP-$WORKER_ID.log"
cd $HYSDS_ROOT_WORK_DIR
# ensure that job gets all 28 Broadwell cores
export OMP_NUM_THREADS=28
env > $LOGFILE
# run celery job worker & # in background, but save its PID
### /home4/esi_sar/verdi/bin/celery worker --app=hysds --concurrency=1 --loglevel=INFO -Q standard_product-s1gunw-topsapp-pleiades_s2037 -n $WORKER_ID -O fair --without-mingle --without-gossip --heartbeat-interval=60 >> $LOGFILE 2>&1 &
/home4/esi_sar/verdi/bin/celery worker --app=hysds --concurrency=1 --loglevel=INFO -Q standard_product-s1gunw-topsapp-pleiades -n $WORKER_ID -O fair --without-mingle --without-gossip --heartbeat-interval=60 >> $LOGFILE 2>&1 &
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
  echo "removing WORKER_DIR: $WORKER_DIR"
  rm -rf "$WORKER_DIR"
}
### trap cleanup SIGTERM
### trap cleanup EXIT

echo "WORKER_DIR: $WORKER_DIR"
echo "CELERY_JOB_WORKER_PID: $CELERY_JOB_WORKER_PID"
### /home4/esi_sar/verdi/bin/python /home4/esi_sar/verdi/ops/hysds/scripts/harikiri_pid.py  $HYSDS_ROOT_WORK_DIR -i 300 -c 120 -p $CELERY_JOB_WORKER_PID -l https://tpfe2.nas.nasa.gov:8443/mozart/api/v0.1/


