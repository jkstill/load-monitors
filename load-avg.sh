

unset LOADS


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

: <<'PYTHIAN-DOC'

Check the load ever $chkFrequency seconds

When the average of the collected load values meets or exceeds $loadAvgThreshold during the  
previous $thresholdSecond then signal an alert

PYTHIAN-DOC

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
debugLoadFudge=10

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


#echo loadCountMax: $loadCountMax

function rotload {            # rotate directory stack - top to bottom
   typeset index=0 index2 _tmpdir idxcnt
   _tmpdir=${LOADS[0]}
   (( idxcnt = ${#LOADS[*]} - 1 ))
   while (( index < idxcnt ))
   do
      (( index2 = index + 1 ))
      LOADS[${index}]=${LOADS[${index2}]}
      (( index = index + 1 ))
   done
   LOADS[${idxcnt}]=$_tmpdir
}



function shiftload {				# shift off bottom load
	typeset maxidx
	(( maxidx = ${#LOADS[*]} - 1 ))
	#rotload
	unset LOADS[${maxidx}]
}


function loads {            # show directory stack
   echo
   typeset index=0
   while (( index < ${#LOADS[*]} ))
   do
      $ECHO "${index} \t${LOADS[index]}"
      (( index = index + 1 ))
   done 
   echo
}


function pushload {			# push down current load
	typeset index index2 idxcnt
	(( idxcnt =  ${#LOADS[*]} ))
	#echo IDXCNT: $idxcnt
	[[ $idxcnt -ge $loadCountMax ]] && {
		shiftload
		(( idxcnt-- ))
	}
	(( index = idxcnt ))
	while (( index > 0 ))
	do
		(( index2 = index - 1))
		LOADS[${index}]=${LOADS[index2]}
		(( index = index - 1))
	done
	LOADS[0]=$(cut  -f1 -d. /proc/loadavg)
	[[ $DEBUG -eq 1 ]] && {
		(( LOADS[0] += $debugLoadFudge ))
	}
}

function myLoadAvg {
   typeset index=0
	typeset loadavg loadsum

	(( idxcnt =  ${#LOADS[*]} ))

	[[ $idxcnt -eq $loadCountMax ]] && {

   	while (( index < ${#LOADS[*]} ))
   	do
			(( loadsum += ${LOADS[index]} ))
      	(( index = index + 1 ))
   	done 

		(( loadavg = $loadsum / $idxcnt ))
		
		echo $loadavg
	}
}


while :
do

	pushload
	loadavg=$(myLoadAvg)
	echo Load Avg: $loadavg

	[[ $loadavg -gt $loadAvgThreshold ]] && {
		echo
		echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
		echo Load Threshold of $loadAvgThreshold exceeded
		echo Current load is $loadavg
		echo 
	}

	sleep $chkFrequency

done



