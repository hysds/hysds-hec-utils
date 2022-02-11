#!/usr/bin/env bash

if [[ -d /nobackupp12/esi_sar/s2037/worker/ ]]; then
	find /nobackupp12/esi_sar/s2037/worker/ -type f -mtime +2.1 | xargs rm -f
	find /nobackupp12/esi_sar/s2037/worker/ -type d -empty -delete
fi

if [[ -d /nobackupp12/esi_sar/s2252/worker/ ]]; then
	find /nobackupp12/esi_sar/s2252/worker/ -type f -mtime +2.1 | xargs rm -f
	find /nobackupp12/esi_sar/s2252/worker/ -type d -empty -delete
fi

if [[ -d /nobackupp12/esi_sar/s2310/worker/ ]]; then
	find /nobackupp12/esi_sar/s2310/worker/ -type f -mtime +2.1 | xargs rm -f
	find /nobackupp12/esi_sar/s2310/worker/ -type d -empty -delete
fi

# make these purging command a cron job by running: crontab /home4/esi_sar/github/hysds-hec-utils/crontab_purge.txt
