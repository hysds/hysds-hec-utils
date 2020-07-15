#!/usr/bin/env python

import os, string, time
import shutil
import sys, getopt
import multiprocessing

import logging
logger = logging.getLogger(__name__)
logging.basicConfig(level=logging.INFO, format='%(asctime)s %(name)s.%(funcName)s +%(lineno)s: %(levelname)-8s [%(process)d] %(message)s')


# ------------------------------------------------
# split a list (l) into evenly sized (n) chunks
def chunks(l, n):
    ### print ('l: ', l)
    ### print ('n: ', n)
    ### print ('len(l): ', len(l))
    return [l[i:i+n] for i in range(0, len(l), n)]


# ------------------------------------------------
# execute data processing jobs on job_number of processes
def parallel_remove(data, job_number):
    total = len(data)
    chunk_size = int(total / job_number)
    slices = chunks(data, chunk_size)
    ### print ('slices: ', slices)

    jobs = []

    for i, s in enumerate(slices):
        j = multiprocessing.Process(target=remove2, args=(i, s))
        jobs.append(j)
    for j in jobs:
        j.start()



def remove2(jobid, paths):
  ### print (jobid)
  ### print (paths)

  for dir in paths:
    remove(dir)



def remove(path):
    """
    Remove the file or directory
    """
    if os.path.isdir(path):
        try:
            logger.info("removing path: %s" % path)
            shutil.rmtree(path)
        except OSError:
            logger.info("Unable to remove folder: %s" % path)
    else:
        try:
            if os.path.exists(path):
                os.remove(path)
        except OSError:
            logger.info("Unable to remove file: %s" % path)



def show_usage():
    print('Usage:')
    print('python parallel_cleanup_cache.py --work_dir=/nobackupp12/lpan/worker/2020/07/11/ --days=3' )
    print('to remove all sub-directories under work_dir that are 3 days old')



def main(argv):
  work_path = '/nobackupp12/lpan/worker/2020/07/11/'
  days = 3

  try:
      opts, args = getopt.getopt(argv,"hd:t:",["work_dir=","days="])
      logger.debug('opts: %s' % opts)
      logger.debug('args: %s' % args)
  except getopt.GetoptError:
      show_usage()
      sys.exit(2)
  for opt, arg in opts:
      if opt in ('-h', '--help'):
          show_usage()
          sys.exit()
      elif opt in ("-w", "--work_dir"):
          work_path = arg
      elif opt in ("-d", "--days"):
          days = arg

  # check if work_path is valid
  if not os.path.isdir(work_path) or not work_path.startswith('/nobackup'):
    logger.error('work_dir %s does not exist or is not /nobackup*.' % work_path)
    show_usage()
    sys.exit(2)

  logger.debug('work_path: %s' % work_path)
  logger.debug('days: %s' % days)

  # check if days is valid
  if int(days) < 3:
    logger.error('We can only remove sub-directories that are 3 or more days old')
    show_usage()
    sys.exit(2)

  # get subdirs under work_path and pass the list to parallel_remove()
  list_subdirs = os.listdir(work_path)
  list_full_subdirs = [os.path.join(work_path, x) for x in list_subdirs]
  parallel_remove(list_full_subdirs, multiprocessing.cpu_count())



if __name__ == '__main__':
  main(sys.argv[1:])


