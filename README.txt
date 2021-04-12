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

. how to parameterize group id in pbs script
  . write a shell script at takes gid as input ($1)
    and calls the pbs script passing in gid with the -W option
    qsub -W group_list=$1 celery_job.pbs
    example:
    -----------
    esi_sar@tpfe2:~/github/hysds-hec-utils> cat celery_job.sh
    #!/bin/bash
    # force an input of pbs group list, e.g., s2037
    if [ $# -eq 0 ]
      then
        echo "# please provide a pbs group list (e.g., s2037, s2252, or s2310)"
        exit 1
    fi

    qsub -W group_list=$1 celery_job.pbs
    -----------

    to run it: sh celery_job.sh s2252

  . celery_job.pbs is as usual except with the following line taken out
    #PBS -W group_list=s2252
    example:
    -----------
    esi_sar@tpfe2:~/github/hysds-hec-utils> cat celery_job.pbs
    #!/bin/bash
    #PBS -l site=static_broadwell:nat=tpfe2
    #PBS -q hysds
    #PBS -l select=1:ncpus=28:model=bro
    #PBS -l min_walltime=12:10:00,max_walltime=24:10:00
    #PBS -o /nobackupp12/esi_sar/logs/581_pbs_output
    #PBS -e /nobackupp12/esi_sar/logs/581_pbs_error
    echo $UID >& tmp.txt
    cd /home4/esi_sar/github/hysds-hec-utils/
    sh 581_job_worker_singularity.sh $PBS_JOBID
    -----------

  . the actual shell script that launches the celery job
    needs the group id for sub-directory creation and queue name.
    here is how to get gid from qstat:
    export PBS_JOBID=$1
    echo "PBS_JOBID=${PBS_JOBID}"
    export gid=`qstat -f $PBS_JOBID | grep egroup | awk '{print $3}'`
    echo "gid=${gid}"

    example:
    -----------
    esi_sar@tpfe2:~/github/hysds-hec-utils> cat 581_job_worker_singularity.sh
    #!/usr/bin/env bash
    # pbs init stuff
    # to get singularity
    source /usr/local/lib/global.profile
    module use /nasa/modulefiles/testing
    module load singularity
    export PBS_JOBID=$1
    echo "PBS_JOBID=${PBS_JOBID}"
    export gid=`qstat -f $PBS_JOBID | grep egroup | awk '{print $3}'`
    echo "gid=${gid}"
    WORKER_ID="pleiades_worker.${PBS_JOBID}"
    TOKENS=$(date +"%Y %m %d")
    IFS=" " read YEAR MONTH DAY <<< ${TOKENS}
    TIMESTAMP=$(date +%Y%m%dT%H%M%S)
    ... ...
    -----------

. how to run
  . to qsub using the s2252 gid:
    sh celery_job.sh s2252

  . currently in celery_job.sh, this shell script is called:
    sh 581_job_worker_singularity.sh $PBS_JOBID

  . can modify job_worker_singularity_s2252.sh
    based on 581_job_worker_singularity.sh
