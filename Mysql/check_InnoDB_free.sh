#! /bin/bash

# As per the Dino's recomendation 
PROGNAME=`/bin/basename $0`
PROGPATH=`echo $0 | sed -e 's,[\\/][^\\/][^\\/]*$,,'`
REVISION=`echo '$Revision: 1749 $' | sed -e 's/[^0-9.]//g'`
. /usr/local/nagios/libexec/utils.sh
#################################################
warn=2048
crit=1024
null="NULL"
usage1="Usage: $0 -H <host> -D <database> [-w <warn>] [-c <crit>]"
usage2="<warn> is kB to warn at.  Default is 2048."
usage3="<crit> is kB to be critical at.  Default is 1024."

# check if parameters are passed (we need atleast Hostname and Database name, as warn and cri are have default values assosiated with them   
if [ $# -lt 1 ]; then
echo "Please provide Host and Database name"
echo $usage1;
        echo
            echo $usage2;
            echo $usage3;
            exit $STATE_UNKNOWN 
fi 

# get parameter values in Variables 

while test -n "$1"; do
    case "$1" in
        -c )
            crit=$2
            shift
            ;;
        -D)
            db=$2
            shift
            ;;
        -w )
            warn=$2
            shift
            ;;
        -h)
            echo $usage1;
        echo 
            echo $usage2;
            echo $usage3;
            exit $STATE_UNKNOWN
        ;;
    -H)
            host=$2
            shift
            ;;
        *)
            echo "Unknown argument: $1"
            echo $usage1;
        echo 
            echo $usage2;
            echo $usage3;
            exit $STATE_UNKNOWN
            ;;
    esac
    shift
done

Query="show table status like 'org';"
#freespace=${echo "$Query" | mysql -t --host=tiber4 mvc | /bin/awk '/InnoDB free:/ {print $38}' }
freespace=$(echo "$Query" | mysql -t --host=$host $db | /bin/awk '/InnoDB free:/ {print $38}' )

echo $host has $freespace kB free


# if null, critical
if [ $freespace == $null ]; then 
exitstatus=$STATE_WARNING
exit $exitstatus;
fi

#if crit > freespace >warn then warning 
if [ $freespace -lt $warn ]; then 
if [ $freespace -ge $crit ]; then 
exitstatus=$STATE_WARNING
exit $exitstatus
fi
fi
# freespace>crit then critical
if [ $freespace -lt $crit ]; then 
exitstatus=$STATE_CRITICAL
exit $exitstatus
fi

# 0<=freespace <warn
if [ $freespace -gt $warn ]; then 
exitstatus=$STATE_OK
exit $exitstatus
fi


