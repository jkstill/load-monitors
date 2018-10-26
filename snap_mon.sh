#!/bin/bash


# watch for high load and run snapNmin.sql 
# if the load is > threshold

# if the load decreases below threshold of LOAD_THRESHOLD during the StatsPack snapshot then the loop continues
# otherwise exits after SNAP_THRESHOLD snapshots are taken

# set the environment here as needed
unset SQLPATH
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
LOAD_THRESHOLD=39
LOAD_THRESHOLD=-1
SNAPCOUNT=0
SNAP_THRESHOLD=3

NOTIFY_LIST='still@pythian.com team12@pythian.com'

while :
do

	# get load avg
	LOADAVG=$($_CUT -f1 -d. /proc/loadavg)
	if [ "$LOADAVG" -gt "$LOAD_THRESHOLD" ]; then

		echo running snapshot now
		(( SNAPCOUNT = SNAPCOUNT + 1 ))
		
		eval "echo \"Statspack - running level 7 snapshot on $HOSTNAME due to load of $LOADAVG\" | $_MAIL  \"$HOSTNAME - High Load Snapshot\" $NOTIFY_LIST"

		$_SQLPLUS /nolog <<-EOF
		connect perfstat/perfstat
		@snapNmin.sql
		exit
		EOF

	fi

	[ "$SNAPCOUNT" -ge "$SNAP_THRESHOLD" ] && exit

	sleep $SLEEPTIME
done



