#! /bin/bash

#This Plug-in monitors the Cassandra Cluster for number of  nodes connected.

# Author - Juned Memon



#########THIS part is for Nagios ################################
PROGNAME=`/usr/bin/basename $0`
PROGPATH=`echo $0 | sed -e 's,[\\/][^\\/][^\\/]*$,,'`
REVISION=`echo '$Revision: 1749 $' | sed -e 's/[^0-9.]//g'`
#. $PROGPATH/utils.sh
.  /usr/local/nagios/libexec/utils.sh


######################################################################

#Function to print Usage
function usage
{
usage="Usage: $0  [-w <WARN>] [-c <CRIT>] -H <HOST> -P <PORT>"
echo $usage
usage="<WARN> is Number of Live Nodes in Cassandra Cluster  for Warning state   Default is 3."
echo $usage
usage="<CRIT> is Number of Live  Nodes in Cassandra Cluster  for Critical State. Defalt is 2."
echo $usage
usage="<HOST> of cassandra node; Default is 127.0.0.1"
echo $usage
usage="<PORT>  JMX port ; Default is 7199 "
echo $usage
exit $STATE_UNKNOWN
}


WARN=3
CRIT=2
HOST="127.0.0.1"
PORT=7199
#####################################################################
# get parameter values in Variables

while test -n "$1"; do
    case "$1" in
        -c )
            CRIT=$2
            shift
            ;;
        -w )
            WARN=$2
            shift
            ;;
        -h)
            usage
            ;;
         -H)
            HOST=$2
            shift
            ;;
         -P)
            PORT=$2
            shift
            ;;

         *)
            echo "Unknown argument: $1"
            usage
            ;;
    esac
    shift
done

#####################################################################

UP=$(nodetool -h $HOST -p $PORT ring | grep Up | wc -l )
IP=$(nodetool -h $HOST -p $PORT ring |  grep Up | awk '{printf $1 " ; "}' )


#if CRIT > UP >WARN then WARNing
if [ $UP -lt $WARN ]; then
if [ $UP -ge $CRIT ]; then
exitstatus=$STATE_WARNING
echo "WARNING : $UP live  nodes in Cassandra Ring. [$IP] "
exit $exitstatus
fi
fi
# UP>CRIT then CRITical
if [ $UP -lt $CRIT ]; then
exitstatus=$STATE_CRITICAL
echo "CRITICAL : $UP live  nodes in Cassandra Ring. [$IP] "
exit $exitstatus
fi

# 0<=UP <WARN
if [ $UP -gt $WARN ]; then
exitstatus=$STATE_OK
echo "OK : $UP live  nodes in Cassandra Ring. [$IP] "
exit $exitstatus
fi

