#!/usr/bin/env python
# +----------------------------------------------------------------------+
# |                                                                      |
# |       _                      _   __  __                              |
# |      | |                    | | |  \/  |                             |
# |      | |_   _ _ __   ___  __| | | \  / | ___ _ __ ___   ___  _ __    |
# |  _   | | | | | '_ \ / _ \/ _` | | |\/| |/ _ \ '_ ` _ \ / _ \| '_ \   |
# | | |__| | |_| | | | |  __/ (_| | | |  | |  __/ | | | | | (_) | | | |  |
# |  \____/ \__,_|_| |_|\___|\__,_| |_|  |_|\___|_| |_| |_|\___/|_| |_|  |
# |                                                                      |
# | Author : Juned Memon            Email : junaid18183@gmail.com        |
# +----------------------------------------------------------------------+


# +----------------------------------------------------------------------+
# | Version : 24022016                                                   |
# | Script  : check_rsnapshot.py                                         |
# | License : GPLv3                                                      |
# |                                                                      |
# +----------------------------------------------------------------------+

import commands,os

LOG_PATH='/var/log/rsnapshot/'

###########################################################################
def check_log (logfile):
        cmd="tail -n1 "+LOG_PATH+logfile
        status, output = commands.getstatusoutput(cmd)
        if status :
                print "can not open log file"
                exit(2)
        log = output
        logfile = logfile[:-4]
        alert_name = "Rsnapshotmonitor_"+logfile
        performance_date ="-"

        if 'completed successfully' in  log :
                status=0
                statustext="OK - Last Backup for %s has completed successfully" %logfile

        elif 'bin' in log or 'pid' in log or 'mv' in log :
                status=0
                statustext="OK - The Backup for %s is still running" %logfile
        else :
                status=2
                statustext="CRITICAL - Last Backup for %s had Failed" %logfile

        print  "%s %s %s %s" %(status,alert_name,performance_date,statustext)
###########################################################################
for file in os.listdir(LOG_PATH):
        if file.endswith(".log"):
                check_log (file)

