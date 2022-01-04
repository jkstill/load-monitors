#!/bin/bash


# watch for high load and run snapper.sh 
# if the load is > threshold

# exits after SNAP_THRESHOLD snapshots are taken

# call with snapper_mon.sh <load_threshold> <duration_seconds>
# eg. run snapper for 3 minutes when the load is 35+ 
#     exit after running 3 times
#
# snapper_mon.sh 35 180 3
# 
# if called with no args it will default to snapper_mon.sh 40 120 3

LOAD_THRESHOLD=$1
: ${LOAD_THRESHOLD:=40}

SNAP_DURATION=$2
: ${SNAP_DURATION:=120}

SNAP_THRESHOLD=$3
: ${SNAP_THRESHOLD:=3}

# set the environment here as needed
unset SQLPATH
export PATH=$ORACLE_HOME/bin:$PATH
unset ORAENV_ASK
PATH=$PATH:/usr/local/bin
. /usr/local/bin/oraenv <<< c12 >/dev/null

_CUT=$(./hard-path.sh cut)
[[ -x $_CUT ]] || {
	echo
	echo Cannot locate cut command
	echo aborting
	echo
	exit 1
}

_GREP=$(./hard-path.sh grep)
[[ -x $_GREP ]] || {
	echo
	echo Cannot locate grep command
	echo aborting
	echo
	exit 1
}

_SQLPLUS=$ORACLE_HOME/bin/sqlplus
[[ -x $_SQLPLUS ]] || {
	echo
	echo Cannot locate sqlplus command
	echo aborting
	echo
	exit 1
}

# this will be the path to mailx, mail, cat in that order, as available
# of just plain 'cat ' - see the script
_MAIL=$(./get-mailer.sh);

if ( echo $_MAIL | $_GREP cat >/dev/null ); then
	_MAIL="$_MAIL # "
fi

#echo _MAIL: $_MAIL

SLEEPTIME=60
SNAPCOUNT=0

NOTIFY_LIST='some-dba@yourdomain.com'

while :
do

	# get load avg
	LOADAVG=$($_CUT -f1 -d. /proc/loadavg)
	if [ "$LOADAVG" -ge "$LOAD_THRESHOLD" ]; then

		echo running snapshot now
		(( SNAPCOUNT = SNAPCOUNT + 1 ))
		
		$_SQLPLUS /nolog <<-EOF
		connect / as sysdba
		@snapper_custom.sql $SNAP_DURATION
		exit
		EOF

		eval "echo \"Snapper - just ran snapper on $HOSTNAME due to load of $LOADAVG - results in user_dump\" | $_MAIL \"$HOSTNAME - High Load Snapshot\" $NOTIFY_LIST"
	fi

	[ "$SNAPCOUNT" -ge "$SNAP_THRESHOLD" ] && exit

	sleep $SLEEPTIME
done



