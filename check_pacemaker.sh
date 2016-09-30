#!/bin/bash
# 
# This script is based on
# https://github.com/conceptsandtraining/nagios_pacemaker
# License: GPLv2
# Author: CaT Concepts and Training GmbH <github@concepts-and-training.de>
# Author: Luc de Louw <ldelouw@redhat.com>
# Changes:
#  - Rewrite to use pcs instead of crm to get the script working with RHEL7 and
#    pcs since RHEL lacks the crm shell
# 

PCS="sudo /usr/sbin/pcs"
GREP="/bin/grep"

PROGNAME=`/usr/bin/basename $0`
PROGPATH=`echo $0 | sed -e 's,[\\/][^\\/][^\\/]*$,,'`
REVISION="0.1"

#. $PROGPATH/utils.sh
. /usr/lib64/nagios/plugins/utils.sh

print_usage() {
    echo "Usage  : $PROGNAME [action]"
    echo "Actions:"
    echo "         maintenance: Checks if maintenance property is set to true"
    echo "         standby    : Checks if one or more nodes are in Standby"
    echo "         move       : Checks if there are manually moved resources"
    echo "         offline    : Checks if there are Offline nodes"
    echo "         failed     : Checks if there are failed actions"
    echo "         inactive   : Checks if there are inactive resources"
    echo ""
    echo "Usage  : $PROGNAME --help"
    echo "Usage  : $PROGNAME --version"
}

print_help() {
    print_revision $PROGNAME $REVISION
    echo ""
    print_usage
    echo ""
    echo "pacemaker/corosync status reporter for nagios"
    echo ""
    support
}

check_maintenance() {
    if $PCS config show | $GREP 'maintenance-mode: true' > /dev/null; then
	echo "WARNING: Maintenance Mode is true"
	exit $STATE_WARNING
    else
	echo "OK: Maintenance Mode is false"
	exit $STATE_OK
    fi
}

check_standby() {
    if $PCS config show | $GREP 'standby=on' > /dev/null; then
	echo "WARNING: Standby on a node is on" 
	exit $STATE_WARNING
    else
	echo "OK: No Node in Standby"
	exit $STATE_OK
    fi
}

check_move() {
    if $PCS config show | $GREP 'cli-ban|cli-prefer' > /dev/null; then
	echo "WARNING: Manual move is active..."
	exit $STATE_WARNING
    else
	echo "OK: Manual move is inactive..."
	exit $STATE_OK
    fi
}

check_offline() {
    if $PCS status | $GREP OFFLINE > /dev/null; then
	echo "WARNING: One of more Nodes are Offline (stopped)"
	exit $STATE_WARNING
    else
	echo "OK: All Nodes are Online"
	exit $STATE_OK
    fi
}

check_failed() {
    if $PCS status | awk '/Failed Actions/ {seen = 1} seen {print}' | $GREP -v 'Failed Actions:' > /dev/null; then
	echo "WARNING: Failed actions present..."
	exit $STATE_WARNING
    else
	echo "OK: No failed actions present..."
	exit $STATE_OK
    fi
}


check_inactive() {
    if $PCS status | $GREP "Stopped\|FAILED" > /dev/null; then
	echo "CRITICAL: Inactive resources present..."
	exit $STATE_CRITICAL
    else
	echo "OK: No inactive resources present..."
	exit $STATE_OK
    fi
}

check_connection() {
    if ! $PCS config > /dev/null; then
	echo "CRITICAL: could not connect to Cluster"
	exit $STATE_CRITICAL
    fi
}

# Make sure the correct number of command line
# arguments have been supplied

if [ $# -lt 1 ]; then
    print_usage
    exit $STATE_UNKNOWN
fi

exitstatus=$STATE_UNKNOWN #default
while test -n "$1"; do
    case "$1" in
        --help)
            print_help
            exit $STATE_OK
            ;;
        -h)
            print_help
            exit $STATE_OK
            ;;
        --version)
            print_revision $PROGNAME $REVISION
            exit $STATE_OK
            ;;
        -V)
            print_revision $PROGNAME $REVISION
            exit $STATE_OK
            ;;
	maintenance)
	    check_connection
	    check_maintenance
	    ;;
        standby)
	    check_connection
	    check_standby
	    ;;
	move)
	    check_connection
	    check_move
	    ;;
	offline)
	    check_connection
	    check_offline
	    ;;	
	failed)
	    check_connection
	    check_failed
	    ;;
	inactive)
	    check_connection
	    check_inactive
	    ;;
        *)
            echo "Unknown argument: $1"
            print_usage
            exit $STATE_UNKNOWN
            ;;
    esac
    shift
done

exit $exitstatus
