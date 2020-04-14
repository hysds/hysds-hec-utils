# HySDS HEC Utilities

Misc utilities to help run verdi job worker nodes on NASA NEC, where the PCM cluster may be running in AWS.

hysds_pcm_check_port_forwarded_tunnel_services.sh
-------------------------------------------------

This script is used to test if all forward ports are accessible from Pleiades back to HySDS PCM.

Note: run this script from Pleiades headnode or compute node.

pbs_auto_scale_up.sh
--------------------

This script calls dynamically scales up PBS jobs based on the number of jobs in Ready
state as returned by execing "rabbitmq_queue_info.py".
Run this script continuously on the Pleiades head node.

Assumptions:
* "rabbitmq_queue_info.py" is in path
* Automatic scale-down is handled by harikiri-pid.py in each PBS worker job.
* PBS queue name is "hysds"
