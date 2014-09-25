#! /bin/bash

#This script checks How many messages are available in the queue and if the Number of messages exceeds the threshols sends an alert 

WARN=50000
CRIT=100000 

VHOST="/"
QUEUE="ViApiQueue"

. /usr/local/nagios/libexec/utils.sh


N_M=rabbitmqctl list_queues  | grep $QUEUE | awk '{print $2}'


if [ $N_M -ge $CRIT ]; then
{
        echo "CRITiCAL : $N_M messages in $QUEUE QUEUE "
        exitstatus=$STATE_WARNING
        exit $exitstatus
}
        else
        {
        echo "OK : $N_M messages in $QUEUE QUEUE "
        exitstatus=$STATE_OK
        exit $exitstatus
        }
fi