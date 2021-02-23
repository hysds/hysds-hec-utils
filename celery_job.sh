#!/bin/bash
# force an input of pbs group list, e.g., s2037
if [ $# -eq 0 ]
  then
    echo "# please provide a pbs group list (e.g., s2037, s2252, or s2310)"
    exit 1
fi

qsub -W group_list=$1 celery_job.pbs

