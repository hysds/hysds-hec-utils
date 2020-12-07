#!/usr/bin/env bash

find /nobackupp12/esi_sar/s2037/worker/ -type f -mtime +2.6 | xargs rm -f
find /nobackupp12/esi_sar/s2037/worker/ -type d -empty -delete
find /nobackupp12/esi_sar/s2252/worker/ -type f -mtime +2.6 | xargs rm -f
find /nobackupp12/esi_sar/s2252/worker/ -type d -empty -delete
find /nobackupp12/esi_sar/s2310/worker/ -type f -mtime +2.6 | xargs rm -f
find /nobackupp12/esi_sar/s2310/worker/ -type d -empty -delete

# make these purging command a cron job by running: crontab /home4/esi_sar/github/hysds-hec-utils/crontab_purge.txt
