

# see load-avg-driver.sh for an example script to use these functions

function getScriptPath {
	typeset script=$1
	#echo >&2 debug script: $script
	statResult=$(stat --format=%N $script | sed -e "s/[\`']//g")

	if [ -L "$script" ]; then
		statResult=$(echo $statResult | awk '{ print $3 }')
	fi

	#echo >&2 debug statResult: $statResult
	#stat --format=%N $script | ask '{ print $3 }' | sed -e "s/[\`']//g"
	echo $statResult
}

function rotload {            # rotate stack - top to bottom
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


function loads {            # show stack
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
	typeset debugLoadFudge=10
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
	typeset loadCountMax=$1
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




