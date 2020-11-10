#!/usr/bin/env bash

find /nobackupp12/esi_sar/s2037/worker/ -mtime 3 | xargs rm -f
find /nobackupp12/esi_sar/s2252/worker/ -mtime 3 | xargs rm -f
find /nobackupp12/esi_sar/s2310/worker/ -mtime 3 | xargs rm -f

# make these purging command a cron job by running: crontab /home4/esi_sar/github/hysds-hec-utils/crontab_purge.txt
