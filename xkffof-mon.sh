#!/usr/bin/env bash

# change as needed
NOTIFY_LIST='jkstill@gmail.com,still@pythian.com'

# edit this location as needed
# load the functions
FUNCTIONS_FILE=/home/jkstill/oracle/dba/load-monitors/load-functions.sh; export FUNCTIONS_FILE

# do not edit below here for normal usage

. $FUNCTIONS_FILE

myPath=$(getScriptPath $0)

#echo myPath: $myPath

usage() {
cat <<EOF

Usage: $0

Check the MAPID_KFFOF values average every '-c' seconds.

-c check MAPID_KFFOF every N seconds
   defaults to 3600

-t threshold count
  	alert when previous:current differ by this amount or more
	defaults to 10000

-x set TESTING=1
   This will force an alert, and the script will exit

-v verbose - no terminal output by default

-d debugging output - currently not used
    
EOF

}

: <<'DOC'

When the value of the difference bewtween the previous and current values of MAPID_KFFOF differ
by more than thresholdChgCount, send an alert

Note: Oracle connections are to an ASM instance as SYSASM

DOC

VERBOSE=0
DEBUG=0
TESTING=0

while getopts hc:t:dvx arg
do
	case $arg in
		c) chkFrequency=$OPTARG;;
		t) thresholdChgCount=$OPTARG;;
		d) DEBUG=1;;
		v) VERBOSE=1;;
		x) TESTING=1;;
		h|H|z|Z) usage; exit;;
		*) usage;exit 1;;
	esac
done

# defaults
thresholdChgCount=${thresholdChgCount:-10000}
chkFrequency=${chkFrequency:-60}  # check every N seconds
 
# this will be the path to mailx, mail, cat in that order, as available
# of just plain 'cat ' - see the script
_MAIL=$(./get-mailer.sh);

# this does not seem to work as expected
#if ( echo $_MAIL | $_GREP cat >/dev/null ); then
	#_MAIL="$_MAIL # "
#fi

#echo _MAIL: $_MAIL

# dump data to CSV

mkdir -p csv

declare csvFile=csv/xkffof-mon.csv

[[ -f $csvFile ]] ||  {
	echo "timestamp,indx,mapid_kffof,path_kffof" > $csvFile
}

# all arrays indexed by x$kffof.indx

declare -a files
declare -a mapidKffof

while :
do
	
	declare timestamp=$(date +%Y-%m-%d_%H:%M:%S);

	if [[ $VERBOSE -eq 1 ]]; then
		echo '#########################################'
		echo "### $timestamp"
		echo
	fi
		
	while read indx mapid_kffof path_kffof
	do

		if [[ $VERBOSE -eq 1 ]]; then
			echo "==================================================="
			echo indx: $indx
			echo mapid_kffof: $mapid_kffof
			echo path_kffof: $path_kffof
			echo
			echo 'files[indx]: ' ${files[$indx]}
			echo 'mapidKffof[indx]: ' ${mapidKffof[$indx]}
		fi

		echo "$timestamp,$indx,$mapid_kffof,$path_kffof" >> $csvFile

		# not the first pass through
		# should also catch new files that were not available when the script started
		if [[ ${files[$indx]} != '' ]]; then
			declare mapidKffofGrowth
			(( mapidKffofGrowth= mapid_kffof - mapidKffof[indx] ))

			if [[ $TESTING -eq 1 ]]; then
				echo Setting mapidKffofGrowth for TESTING
				mapidKffofGrowth=$thresholdChgCount
			fi

			if [[ $VERBOSE -eq 1 ]]; then
				echo mapidKffofGrowth: $mapidKffofGrowth
			fi

			# alert here
			if [[ $mapidKffofGrowth -ge $thresholdChgCount ]]; then
				echo "!!! excessive growth in MAPID_KFFOF (X\$KFFOF)"
				declare msg
				msg=$(cat <<-EOM
MAPID_KFFOF : $mapid_kffof \
PATH_KFFOF: $path_kffof \
!!! excessive growth in MAPID_KFFOF (X\$KFFOF)
EOM
)

				#echo "MSG: $msg"
				#echo "mailx: $_MAIL"

				echo $msg | $_MAIL  "$HOSTNAME - excessive mapid_kffof growth" $NOTIFY_LIST
			fi

			if [[ $TESTING -eq 1 ]]; then
				exit
			fi

		fi

		# set these each iteration, as files may change
		files[$indx]="$path_kffof"
		mapidKffof[$indx]=$mapid_kffof

	done < <(
	sqlplus -L -S /nolog <<-EOF 
		connect sys/grok@ora192rac01/+ASM as sysasm
		set pagesize 0
		set linesize 400 trimspool on
		set feedback off
		set head off
		select indx ,mapid_kffof ,path_kffof 
		from x\$kffof 
		order by indx;
		exit;
	EOF
	)

	sleep $chkFrequency

done

