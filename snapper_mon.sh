#!/bin/sh


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

unset SQLPATH
export ORACLE_BASE=/opt/oracle
export ORACLE_HOME=/opt/oracle/product/10g
export ORACLE_SID=PRODRAC2
export PATH=$ORACLE_HOME/bin:$PATH

_CUT=/bin/cut
_SQLPLUS=$ORACLE_HOME/bin/sqlplus
_MAIL=/bin/mail

SLEEPTIME=60
SNAPCOUNT=0

NOTIFY_LIST='still@pythian.com team12@pythian.com'

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

		echo "Snapper - just ran snapper on $HOSTNAME due to load of $LOADAVG - results in user_dump" | $_MAIL -s "$HOSTNAME - High Load Snapshot" $NOTIFY_LIST
	fi

	[ "$SNAPCOUNT" -ge "$SNAP_THRESHOLD" ] && exit

	sleep $SLEEPTIME
done



