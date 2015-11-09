#!/bin/sh


# watch for high load and run snapNmin.sql 
# if the load is > threshold

# if the load decreases below threshold of LOAD_THRESHOLD during the StatsPack snapshot then the loop continues
# otherwise exits after SNAP_THRESHOLD snapshots are taken

export ORACLE_BASE=/opt/oracle
export ORACLE_HOME=/opt/oracle/product/10g
export ORACLE_SID=PRODRAC2
export PATH=$ORACLE_HOME/bin:$PATH

_CUT=/bin/cut
_SQLPLUS=$ORACLE_HOME/bin/sqlplus
_MAIL=/bin/mail

SLEEPTIME=60
LOAD_THRESHOLD=39
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
		
		echo "Statspack - running level 7 snapshot on $HOSTNAME due to load of $LOADAVG" | $_MAIL -s "$HOSTNAME - High Load Snapshot" $NOTIFY_LIST

		$_SQLPLUS /nolog <<-EOF
		connect perfstat/perfstat
		@snapNmin.sql
		exit
		EOF

	fi

	[ "$SNAPCOUNT" -ge "$SNAP_THRESHOLD" ] && exit

	sleep $SLEEPTIME
done



