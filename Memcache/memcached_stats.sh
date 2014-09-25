#!/bin/bash
#
# A Memcached stats plugin for the check_mk nagios system.
# Place me in /usr/lib/check_mk_agent/plugins on the client
# This script is based on memcached-tool (/usr/bin/memcached-tool) (Self-Monitoring, Analysis, and Reporting Technology)
# sudo memcached-tool localhost:11235 stats
#
#Check memcached statics
# http://www.pal-blog.de/entwicklung/memcached/2011/memcached-statistics-stats-command.html

# Following threshold set for max connections
# warning = 100
# critical = 150

VERSION="Version 1.0,"
AUTHOR="2012, Juned Memon <junaid18183@gmail.com>"

LOG=/usr/bin/logger
FLAG=0
STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3
STATE_DEPENDENT=4
crit="No"
null="NULL"
ok="Yes"
Hostname=`hostname`

print_version() {
    echo "$VERSION $AUTHOR"
}

# Show string list
stringlist() {
   string_list=(" accepting_conns auth_cmds auth_errors bytes bytes_read bytes_written cas_badval cas_hits cas_misses cmd_flush cmd_get cmd_set conn_yields connection_structures curr_connections curr_items decr_hits decr_misses delete_hits delete_misses evictions get_hits get_misses incr_hits incr_misses limit_maxbytes listen_disabled_num pid pointer_size rusage_system rusage_user threads time total_connections total_items uptime version")
    # use for loop read all string list
    for i in $string_list;
    do
      echo $i
    done
}

print_help(){
    print_version
    echo ""
    echo "This tool is a Nagios plugin to check a specific stats from stat string via memcached-tool."
    echo "You may provide any stat string as an argument to match a specific"
    echo "memcached-tool. Please note that the output could be distorted if the"
    echo "argument matches various strings, so please make sure to use"
    echo "unique stat string to match."
    echo ""
    echo "Usage: $0 -H localhost -p 11235 -l curr_connections [-w 40] [-c 50]"
    echo ""
    echo "Options:"
    echo "  -s/--stringlist"
    echo "     A string list can be check via -s."
    echo "  -l/--list"
    echo "     A list can be defined via -l. Choose total_connections and curr_connections."
    echo "     Choose -s if use list all strings"
    echo "     Ex: $0 -s"
    echo "  -H/--host"
    echo "     A host can be defined via -H. Choose localhost or 127.0.0.1."
    echo "     Default is: localhost"
    echo "  -p/--port"
    echo "     A port can be defined via -p. Choose 11211."
    echo "     Default is: 11211"
    echo "  -w/--warning"
    echo "     Defines a warning level for a target which is explained"
    echo "     below. Default is: off"
    echo "  -c/--critical"
    echo "     Defines a critical level for a target which is explained"
    echo "     below. Default is: off"
    echo "     "
    exit 3
}
if [ "$#" -lt 1 ]
then
  print_help
fi

while test -n "$1"; do
    case "$1" in
        -help|-h)
            print_help
            exit 3
            ;;
        --list|-l)
            list=$2
            shift
            ;;
        --stringlist|-s)
            stringlist
            exit 3
            ;;
        --host|-H)
            host=$2
            shift
            ;;
        --port|-p)
            port=$2
            shift
            ;;
        --warning|-w)
            warning=$2
            shift
            ;;
        --critical|-c)
            critical=$2
            shift
            ;;
        *)
            echo "Unknown argument: $1"
            print_help
            exit 3
            ;;
        esac
    shift
done

# Set the default values if user not pass with the script
if [ "$host" = "" ];then
  host="localhost"
fi
if [ "$port" = "" ]; then
  port="11235"
fi
if [ "$list" = "" ] ; then
  list="curr_connections"
fi

statics=`memcached-tool $host:$port stats |grep "$list" | xargs echo |awk '{print $2}' | tr -cd '[0-9]'`
#echo $statics

if [ -n "$warning" -a -n "$critical" ]
then
  if [ $statics -ge "$critical" ];then
    echo "CRITICAL -  Memcached status for "$list": "$statics" |'$list'=$statics "
    exit $STATE_CRITICAL;
  elif [ $statics -ge "$warning" -a "$statics" -lt "$critical" ];then
    echo "WARNING -  Memcached stats for "$list": $statics |'$list'=$statics "
    exit $STATE_WARNING;
  else
    echo "OK - Memcached stats for "$list": $statics |'$list'=$statics"
    exit $STATE_OK;
  fi
else
  echo "OK - Memcached stats for "$list": $statics |'$list'=$statics"
  exit $STATE_OK;
fi

# End