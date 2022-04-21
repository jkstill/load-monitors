
# load the functions

declare scriptPath=$(dirname $0)

cd $scriptPath
[[ $? -ne 0 ]] && { echo "failed to cd to $scriptPath"; exit 1; }

FUNCTIONS_FILE=$scriptPath/load-functions.sh; export FUNCTIONS_FILE

[[ -r $FUNCTIONS_FILE ]] || { echo "cannot source $FUNCTIONS_FILE"; exit 1; }

source ${FUNCTIONS_FILE}

declare -a LOADS=()

usage() {
cat <<EOF

Usage: $0

Check the load average every '-c' seconds.
When the load average reaches '-l' during the load '-s' seconds then print alert

-c check the load every N seconds
   defaults to 60
-s check the average over the past N seconds
   defaults to 60
-l the load average threshold to check
   defaults to 5

EOF

}

: <<'DOC'

Check the load every $chkFrequency seconds

When the average of the collected load values meets or exceeds $loadAvgThreshold during the  
previous $thresholdSecond then signal an alert

DOC

DEBUG=0

while getopts hc:s:l:d arg
do
	case $arg in
		c) chkFrequency=$OPTARG;;
		s) thresholdSeconds=$OPTARG;;
		l) loadAvgThreshold=$OPTARG;;
		d) DEBUG=1;;
		h|H|z|Z) usage; exit;;
		*) usage;exit 1;;
	esac
done

# defaults
thresholdSeconds=${thresholdSeconds:-900}
chkFrequency=${chkFrequency:-60}  # check every N seconds
loadAvgThreshold=${loadAvgThreshold:-5}

(( loadCountMax = ($thresholdSeconds / $chkFrequency) + 1 ))
#echo thresholdSeconds: $thresholdSeconds

[[ $chkFrequency -ge $thresholdSeconds ]] && {
	echo
	echo check frequency cannot be less than threshold seconds
	echo 
	exit 1
}

# +1 may be used if thresholdSeconds not evenly divisible by chkFrequency
#(( loadCountMax = ($thresholdSeconds / $chkFrequency) + 1 ))
(( loadCountMax = ($thresholdSeconds / $chkFrequency) + 1 ))


while :
do

	pushload
	loadavg=$(myLoadAvg $loadCountMax)
	echo Load Avg: $loadavg

	[[ $loadavg -gt $loadAvgThreshold ]] && {
		echo
		echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
		echo Load Threshold of $loadAvgThreshold exceeded
		echo Current load is $loadavg
		echo 
		echo Do something here!
		echo 
	}

	sleep $chkFrequency

done



