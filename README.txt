. celery.pbs submit job
  qsub -q hysds wvcc_celery.pbs

. to check job status
  qstat -u lpan
  qstat -q hysds

. to start an interactive celery job
  celery worker --app=hysds --concurrency=1 --loglevel=INFO -Q pleiades_job_worker-small -n 1000 -O fair --without-mingle --without-gossip --heartbeat-interval=60

. to submit an interactive job
  qsub -I -q hysds -lselect=1:ncpus=1:model=bro,walltime=0:10:00

. to qdel many
  qstat -u lpan|awk '{print "qdel " $1}' >& rmall.sh

  qstat -u lpan | awk '{ if ($8 == "R" || $8 == "Q") print "qdel "$1;}'|sh

. to set prlimit for sshd
  ps -fu lpan | grep sshd               (to get <pid>)
  prlimit --pid <pid>                   (to see current settings)
  prlimit --nofile=10000 --pid <pid>    (to set NOFILE)

. (verdi) [lpan@hfe1 hysds-hec-utils]$ id
  uid=10613(lpan) gid=23110(g23110) groups=23110(g23110),42037(s2037)

. (verdi) [lpan@hfe1 hysds-hec-utils]$ acct_ytd s2037
                       Fiscal                                                 YTD      Project  
Project  Host/Group     Year       Used   % Used         Limit      Remain    Usage   Exp Date  
-------- ------------- ------ ----------- ---------  ----------- ----------  -------  ------------
s2037    hecc          2020    42688.761   151.09    28254.000   -14434.761  279.94   09/30/20

. to get lustre quota
  lfs quota -u lpan /nobackupp12/

. to run autoscaling in the background
  pbs_auto_scale_up.sh s2037 50 > pbs_auto_scale_up-s2037_50.log 2>&1 &
  or use
  auto_scaling_launcher.sh

. to start cron job for disk purging
  crontab < crontab_purge.txt

. to get the gid of a job
  echo `qstat -f 10639466.pbspl1 | grep egroup | awk '{print $3}'`

. new way of qsub using different gid as input:
  sh celery_job.sh s2310
  (The shell script celery_job.sh will "pass" the gid to celery_job.pbs.
   celery_job.pbs calls 581_job_worker_singularity.sh, which takes $PBS_JOBID
   as input. 581_job_worker_singularity.sh gets the gid by calling
   qstat using $PBS_JOBID as input. In this way, the entire job submission
   is parameterized and there is no need to hardcode gid in any script.)
