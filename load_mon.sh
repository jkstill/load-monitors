#!/bin/sh


# get some data load - sar is not granular enough
# output is CSV timestamp,load
# runs forever  - kill it to stop it

_CUT=/bin/cut
_DATE='/bin/date +%Y-%m-%d_%H-%M-%S'

SLEEPTIME=10

while :
do
	# get load avg
	LOADAVG=$($_CUT -f1 -d' ' /proc/loadavg)
	TIMESTAMP=$($_DATE)
	echo \"$TIMESTAMP\",\"$LOADAVG\"
	sleep $SLEEPTIME
done



