#!/bin/bash

# Nagios checker for mpt-status
# Made not in China by Tonop

# List of states for issuing Critical, based on mpt-status exit code.
# If mpt-status exits with 0, script ends with OK;
# if exiting bitmask status had any of ERRSTATES - ends with Critical;
# any other (none of exitcode bitmask was in ERRSTATES) - Warning.
# For more info read man mpt-status(8)
# Possible values:
# unknown lvfail lvdegraded lvresync physfail physwarn
ERRSTATES="unknown lvfail physfail"

MPTOUT=`sudo mpt-status $@`
MPTEXIT=$?
if [[ $MPTEXIT -ne 0 ]] && [[ "$MPTOUT" == *mptctl* ]]; then
    echo "mptctl failed!"
    echo "$MPTOUT"
    exit 2
fi

if [[ $MPTEXIT -eq 0 ]]; then
    echo "State: OK"
    echo "$MPTOUT"
    exit 0
fi

MPTSTATE="State:"
EXITSTATE=0

# check for physwarn state
if ((($MPTEXIT/32)==1)); then
    MPTSTATE="$MPTSTATE PhysDiscWarn"
    MPTEXIT=$(($MPTEXIT%32))
    if [[ "$ERRSTATES" == *physwarn* ]]; then
        EXITSTATE=2
    else
        [[ $EXITSTATE -ne 2 ]] && EXITSTATE=1
    fi
fi

# check for physfail state
if ((($MPTEXIT/16)==1)); then
    MPTSTATE="$MPTSTATE PhysDiscFail"
    MPTEXIT=$(($MPTEXIT%16))
    if [[ "$ERRSTATES" == *physfail* ]]; then
        EXITSTATE=2
    else
        [[ $EXITSTATE -ne 2 ]] && EXITSTATE=1
    fi
fi

# check for lvresync state
if ((($MPTEXIT/8)==1)); then
    MPTSTATE="$MPTSTATE LVResyncing"
    MPTEXIT=$(($MPTEXIT%8))
    if [[ "$ERRSTATES" == *lvresync* ]]; then
        EXITSTATE=2
    else
        [[ $EXITSTATE -ne 2 ]] && EXITSTATE=1
    fi
fi

# check for lvdegraded state
if ((($MPTEXIT/4)==1)); then
    MPTSTATE="$MPTSTATE LVDegraded"
    MPTEXIT=$(($MPTEXIT%4))
    if [[ "$ERRSTATES" == *lvdegraded* ]]; then
        EXITSTATE=2
    else
        [[ $EXITSTATE -ne 2 ]] && EXITSTATE=1
    fi
fi

# check for lvfail state
if ((($MPTEXIT/2)==1)); then
    MPTSTATE="$MPTSTATE LVFailed"
    MPTEXIT=$(($MPTEXIT%2))
    if [[ "$ERRSTATES" == *lvfail* ]]; then
        EXITSTATE=2
    else
        [[ $EXITSTATE -ne 2 ]] && EXITSTATE=1
    fi
fi

# check for unknown state
if ((($MPTEXIT/1)==1)); then
    MPTSTATE="$MPTSTATE unknown"
    MPTEXIT=$(($MPTEXIT%1))
    if [[ "$ERRSTATES" == *unknown* ]]; then
        EXITSTATE=2
    else
        [[ $EXITSTATE -ne 2 ]] && EXITSTATE=1
    fi
fi

echo $MPTSTATE
echo "$MPTOUT"
exit $EXITSTATE

