import os
import sys
import time
import shutil

import logging
logger = logging.getLogger(__name__)
logging.basicConfig(level=logging.INFO, format='%(asctime)s %(name)s.%(funcName)s +%(lineno)s: %(levelname)-8s [%(process)d] %(message)s')

#----------------------------------------------------------------------
def remove(path):
    """
    Remove the file or directory
    """
    if os.path.isdir(path):
        try:
            shutil.rmtree(path)
        except OSError:
            logger.error('Unable to remove folder: %s' % path)
    else:
        try:
            if os.path.exists(path):
                os.remove(path)
        except OSError:
            logger.error('Unable to remove file: %s' % path)

#----------------------------------------------------------------------
def cleanup(number_of_days, path):
    """
    Removes files from the passed in path that are older than or equal 
    to the number_of_days
    """

    ### print ('number_of_days: ', number_of_days)
    ### time_in_secs = time.time() - (number_of_days * 24 * 3600)
    time_in_secs = time.time()
    ### print ('time_in_secs: ', time_in_secs)

    for root, dirs, files in os.walk(path, topdown=False):
        # remove all subdirs with name 'cache'
        for dir in dirs:
            if dir == 'cache':
              full_path = os.path.join(root, dir)
              try:
                stat = os.stat(full_path)
                ### print ('stat.st_mtime: ', stat.st_mtime)
                if stat.st_mtime <= time_in_secs:
                    remove(full_path)
                    logger.info('removed dir: %s' % full_path)
              except FileNotFoundError:
                pass

    for root, dirs, files in os.walk(path, topdown=False):
        # remove old files or unlink old symbolic links
        for file_ in files:
            full_path = os.path.join(root, file_)
            try:
              stat = os.stat(full_path)
              freshness = (time_in_secs-stat.st_mtime)/3600./24.
              if freshness > number_of_days:
                  ### print ('time_in_secs: ', time_in_secs)
                  ### print ('stat.st_mtime: ', stat.st_mtime)
                  ### print ('freshness: ', int(freshness))
                  remove(full_path)
                  logger.info('removed dir: %s' % full_path)
            except FileNotFoundError:
              islink = os.path.islink(full_path)
              if islink:
                os.unlink(full_path)
                logger.info('unlinked path: %s' % full_path)

        # if dir is empty, remove it
        if not os.listdir(root):
            remove(root)
            logger.info('removed root: %s' % root)



def show_usage():
    print('Usage:')
    print('python cleanup_old_files_dirs.py <num of days> <path>' )
    print('to remove files under <path> that are <num of days> old')
    print('Example:')
    print('python cleanup_old_files_dirs.py 3 /nobackupp12/lpan/logs/' )
    print('removes log files under /nobackupp12/lpan/logs/ that are 3 old')



#----------------------------------------------------------------------
if __name__ == "__main__":

    if len(sys.argv) <= 1:
      show_usage()
      sys.exit(2)

    days, work_path = int(sys.argv[1]), sys.argv[2]

    # check if work_path is valid
    if not os.path.isdir(work_path) or not work_path.startswith('/nobackup'):
      logger.error('work_dir %s does not exist or is not /nobackup*.' % work_path)
      sys.exit(2)

    cleanup(days, work_path)

