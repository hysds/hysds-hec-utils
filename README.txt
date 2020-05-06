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
