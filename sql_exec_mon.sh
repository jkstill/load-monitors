#!/bin/sh


# I suspect there are a large number of executions
# causing high loads during a short period of time
# this script will collect sql_id + executions from v$sqlstats
# select from the avail sql_executions table

# call with sql_exec_mon.sh 
# exits after approx 1 day of snapshots

unset SQLPATH
export ORACLE_BASE=/opt/oracle
export ORACLE_HOME=/opt/oracle/product/10g
export ORACLE_SID=PRODRAC2
export PATH=$ORACLE_HOME/bin:$PATH

_CUT=/bin/cut
_SQLPLUS=$ORACLE_HOME/bin/sqlplus

SLEEPTIME=60
SNAP_THRESHOLD=1440
SNAPCOUNT=0

while :
do

	(( SNAPCOUNT = SNAPCOUNT + 1 ))

	# get load avg
	LOADAVG=$($_CUT -f1 -d. /proc/loadavg)

	$_SQLPLUS /nolog <<-EOF
	connect avail/XXXXX
	insert into sql_executions
	select sql_id, executions, sysdate, $LOADAVG
	from v\$sqlstats;
	@@update_save_sqlstats.sql
	commit;
	exit
	EOF

	[ "$SNAPCOUNT" -ge "$SNAP_THRESHOLD" ] && exit

	sleep $SLEEPTIME

done



