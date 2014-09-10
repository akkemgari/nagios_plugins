#!/bin/bash
#This Plug-in monitors the HDFS direcory for number of files in it and sends the alert basis on the threshold


# Author - Juned Memon
#######################################################################################
#Nagios Exit Status
STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3
STATE_DEPENDENT=4
########################################################################################



#Function to print Usage
function usage
{
usage1="Usage: $0  [-w <WARN>] [-c <CRIT>] -D <DIR> "
usage2="<WARN> is Number of Files for WARNING state   Default is 2500."
usage3="<CRIT> is Number of Files for CRITICAL state  Default is 3000.\n <DIR> the abosulte path of directory. Default is PWD. "
echo $usage1
echo""
echo $usage2
echo""
echo "$usage3"


exit $STATE_UNKNOWN
}

######################################################################
#Default thresholds
WARN=2500
CRIT=3000
DIR=.

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
         -D)
            DIR=$2
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

COUNT=$(hadoop fs -ls $DIR | head -n1 | awk  '{print $2}'  )

if [[ -z "$COUNT" ]]; then
COUNT=0
fi


#if CRIT > DOWN >WARN then WARNing
if [ $COUNT -ge $WARN ]; then
if [ $COUNT -lt $CRIT ]; then
exitstatus=$STATE_WARNING
echo " WARNING : $DIR has $COUNT files in it "
exit $exitstatus
fi
fi
# DOWN>CRIT then CRITICAL
if [ $COUNT -ge $CRIT ]; then
exitstatus=$STATE_CRITICAL
echo " CRITICAL : $DIR has $COUNT files in it "
exit $exitstatus
fi

# 0<=DOWN <WARN
if [ $COUNT -le $WARN ]; then
exitstatus=$STATE_OK
echo " OK : $DIR has $COUNT files in it "
exit $exitstatus
fi
