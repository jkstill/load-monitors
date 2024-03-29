#!/usr/bin/env bash

usage () {

cat <<-EOF

 This script expect to check a numeric value

 The SQL script that is run should return only one value, and that should an integer

 The file specified via -M should be a list of commands that can be run from sqlplus

 If the email address file is specified via -E option, then the first line of that file
 will be the message, and all following lines will be email addresses
 If there are no email address lines (1 or less non-blank, non comment lines) in the file,
 then no mail will be sent or even attempted

 -a|A post alert sleep time - wait N seconds before checking again for an alert condition
 -c|C check interval - how many seconds to sleep in the loop
 -d|D debug mode
 -e|E email file - default is coproc-email.txt
 -i|I string for comparison - either -T or -I must be used
 -l|L character to use as a delimiter in the cmdFile - default is ':'
 -m|M cmd file - commands that work from sqlplus.  these commands are run when an alert is triggered
      the output is included in any email - default file is coproc-sqlplus-cmds.txt
 -n|N Dry run.  Read files, connect to database, get the date, and exit.  Best if used with -V
 -o|O One Shot. Exit after the first alert is sent.
 -p|P coproc credentials file.  This is a shell script that returns
      the connect string for sqlplus - default is ./coproc-creds.sh
 -r|R read timeout - used when getting output from sqlplus - default is 1
 -s|S the sql script that outputs an integer
      default is coproc-int-trigger.sql
 -t|T threshold integer value for the alert - no default, must be included on the cmd line
 -v|V verbose output
 -x|X touch the /tmp/coproc-mon.exit file, causing any running coproc-mon.sh to exit

 The sql script coproc-init.sql is used to to setup the environment after logging into sqlplus
 This script is required.

 The script can be made to exit by touching file /tmp/coproc-mon.exit

EOF

}


declare cmdDelimiter=':'
declare chkInterval=60 # seconds
declare cmdFile='coproc-sqlplus-cmds.txt'
declare emailFile='coproc-email.txt'
declare DEBUG=N
declare VERBOSE=N
declare coprocCredsFile='./coproc-creds.sh'
declare readTimeOut=1
declare sqlplusScript='coproc-int-trigger.sql'
declare coprocInitFile='coproc-init.sql'
declare alertThreshold=1
declare pidLockFile='/tmp/coproc-mon.pid'
declare sqlPrompt='SQL-CoProc# '
declare dryRun='N'
declare stringToCompare=''
declare stringComparison='N'
declare postAlertSleepTime=300
declare oneShotAlert='N'
declare terminator='SQL_DONE'

declare scriptHome=$(dirname $0)

cd $scriptHome || { echo "could not chdir to $scriptHome"; exit 1; }

declare logDir=./logs
mkdir -p $logDir
declare logFile=$logDir/coproc-mon-$(date '+%Y-%m-%d_%H-%M-%S').log
touch $logFile

declare pidFile='/tmp/coproc-mon.pid'
declare exitFile='/tmp/coproc-mon.exit'

while getopts a:A:c:C:e:E:i:I:l:L:m:M:r:R:s:S:t:T:dDhHnNoOzZvVxX arg
do
	case $arg in
		a|A) postAlertSleepTime=$OPTARG;;
		c|C) chkInterval=$OPTARG;;
		d|D) DEBUG='Y';;
		e|E) emailFile=$OPTARG;;
		i|I) stringComparison='Y';stringToCompare="$OPTARG";;
		m|M) cmdFile=$OPTARG;;
		l|L) cmdDelimiter=$OPTARG;;
		n|N) dryRun='Y';;
		o|O) oneShotAlert='Y';;
		r|R) readTimeOut=$OPTARG;;
		s|S) sqlplusScript=$OPTARG;;
		t|T) alertThreshold=$OPTARG;;
		v|V) VERBOSE='Y';;
		x|X) touch $exitFile;exit 0;;
		h|H|z|Z) usage;exit 0;;
	esac
done

set -u

[[ -z "$alertThreshold" ]] && [[ -z "$stringToCompare" ]] && { echo "please use -T or -I"; usage; exit 1; }

# one of -T or -I must be used
(echo $readTimeOut | grep -qE '^[[:digit:]\.]+$') || { echo "-r '$readTimeOut' is not numeric"; exit 1; }
(echo $alertThreshold | grep -qE '^[[:digit:]\.]+$') || { echo "-t '$alertThreshold' is not numeric"; exit 1; }
(echo $chkInterval | grep -qE '^[[:digit:]\.]+$') || { echo "-t '$chkInterval' is not numeric"; exit 1; }

(echo $postAlertSleepTime | grep -qE '^[[:digit:]\.]+$') || { echo "-t '$postAlertSleepTime' is not numeric"; exit 1; }

[[ -r $coprocInitFile ]] || { echo "cannot read $coprocInitFile"; exit 1; }
[[ -r $sqlplusScript ]] || { echo "cannot read $sqlplusScript"; exit 1; }
[[ -r $cmdFile ]] || { echo "cannot read $cmdFile"; exit 1; }
[[ -x $coprocCredsFile ]] || { echo "cannot execute $coprocCredsFile"; exit 1; }


declare coprocCreds=$(eval $coprocCredsFile)
#echo "coprocCreds: $coprocCreds"

debug () {
	local msg="$@"
	[[ $DEBUG == 'Y' ]] || { return 0; }
	echo "##############################################" >&2
	echo "## $msg" >&2
	echo "##############################################" >&2
	return 0
}

warning () {
	local msg="$@"
	echo "===" >&2
	echo "=== Warning:" >&2
	echo "=== $msg" >&2
	echo "===" >&2
}

getLogfileName () {
	echo $logFile
}

verbose () {
	[[ $VERBOSE == 'Y' ]] && { return 0; }
	return 1
}

getPidLockFile () {
	echo $pidFile
}

getCoprocExitFile () {
	echo $exitFile
}

pidLock () {

	local PID=$$
	$( verbose ) && {
		echo "======================"
		echo current PID: $PID
	}
	local myScriptName=$(basename $0)
	
	# does log file exist?
	local lockFileExists=Y

	[[ -r $(getPidLockFile) ]] || { lockFileExists=N; }

	if [[ $lockFileExists == 'Y' ]]; then
		$( verbose ) && { echo LockFile Exists; }
		local testPID
		mapfile -t -n 1 testPID < <(cat $(getPidLockFile))
		# re-use the file if the pid does not exist
		# or if the pid exists, but is not this script

		pidExe=$(ps -p $testPID -o cmd -h)

		$( verbose ) && {
			echo testPID: $testPID
			echo pidExe: $pidExe
			echo myScriptName: $myScriptName
		}

		if [ -n "$pidExe" ];  then  # something running on this PID if not blank
			# if it is this script running
			$( verbose ) && { echo pidExe is non-blank; }
			if $(echo "$pidExe" | grep -hq "$myScriptName"); then
				$( verbose ) && {
					echo pidExe: $pidExe
					echo myScriptName: $myScriptName
					echo "already running $myScriptName with PID: $testPID"
				}
				ps -p $testPID -o user,pid,cmd,
				exit 2
				# if something running on this pid, but not this script
			fi
		fi

		# must be a dead pid, or another process that got the same ID as previous execution of this script

	fi

	echo $$ > $(getPidLockFile)

}


pidLock

# delete this file if it exists for some reason
# otherwise the script will exit prematurely
rm -f "$(getCoprocExitFile)" 

logger () {
	local logmsg="$@"
	date '+%Y-%m-%d_%H-%M-%S' >> $(getLogfileName)
	echo "$logmsg" >> $(getLogfileName)
}

# be VERY careful changing this
# it works as is
# I have attempted storing the values in an array, and retrieving via a 'displayOutput' function
# for some reason, that never works properly
readOutput () {
	# every bash since at least 3.2.25 (2009) supports -u
	debug "readOutput"
	IFS=' ' 
	while read -r -t $readTimeOut -u "$cpSTDOUT" output
	do
		#logger "$output"
		case "$output" in
			$terminator) 
				debug "Caught Terminator - $terminator !";
				break;;
			*) debug "output: $output";
				echo "$output";;
		esac
	done 

}

# read a single line and return it
readLine () {
	#while TMOUT=$readTimeOut read output <&"$cpSTDOUT"
	read -t $readTimeOut output <&"$cpSTDOUT"
	[[ $? -gt 128 ]] && { 
		warning "timed out getting output"; 
		logger "timed out getting output - readLine()"; 
	}
	echo "$output"
	logger "$output"
}

# commands are things that do not generate output
# anything that is not SQL
sendCmd () {
	local cmd="$@"
	debug "sending command: '$cmd'"

	[[ $DEBUG == 'Y' ]] && {
		echo "cmd hexdump:"
		echo $cmd | hexdump -C
	}

	echo "$cmd" >&"$cpSTDIN"
	echo "" >&"$cpSTDIN"
}

sendSql () {
	local sql="$@"
	debug "sending sql: '$sql'"

	[[ $DEBUG == 'Y' ]] && {
		echo "sql hexdump:"
		echo $sql | hexdump -C
	}

	sendCmd "$sql"
	echo "prompt $terminator" >&"$cpSTDIN"
	echo "" >&"$cpSTDIN"
}


cleanup () {
	readOutput
	sendCmd 'exit'
	sendCmd
	readOutput
	rm -f "$(getPidLockFile)"
	rm -f "$(getCoprocExitFile)" 
}


declare -a cmds emailAddresses initCmds  sqlplusCmds
declare emailMsg=''
declare emailAddressList=''

mapfile -t initCmds < <(grep -vE -- '^\s*#|^\s*$|^\s*--' $coprocInitFile)
#mapfile -t sqlplusCmds < <(grep -vE -- '^\s*#|^\s*$|^\s*--' $cmdFile)
mapfile -t sqlplusCmds < <(grep -E '^(SQL|CMD):'  $cmdFile)

if [[ -r $emailFile ]]; then
	echo "processing mail from $emailFile"
	logger "processing mail from $emailFile"

	mapfile -t -n 1 emailMsg < <(grep -vE '^\s*#|^\s*$' $emailFile)

	# remove the first line as it should be the email message
	mapfile -t -s 1 emailAddresses < <(grep -vE '^\s*#|^\s*$' $emailFile)

	for email in "${emailAddresses[@]}"
	do
		emailAddressList="${emailAddressList},${email}"
	done

	emailAddressList=${emailAddressList:1}

else
	echo "not processing email"
	logger "not processing email"
fi


$(verbose) &&  {
	echo >&2
	echo '== initCmds ==' >&2
	for cmd in "${initCmds[@]}"
	do
		echo "  cmd: $cmd" >&2
	done

	echo >&2
	echo '== sqlplusCmds ==' >&2
	for cmd in "${sqlplusCmds[@]}"
	do
		echo "  cmd: $cmd" >&2
	done

	echo >&2
	echo '== email msg ==' >&2
	echo "$emailMsg" >&2

	echo >&2
	echo '== email addresses ==' >&2
	for email in "${emailAddresses[@]}"
	do
		echo "  email: $email" >&2
	done
	echo
	echo emailAddressList: "$emailAddressList" >&2
	echo
}

runSqlInit () {
	# run the init cmds
	# no need to read output as there should not be any
	for cmd in "${initCmds[@]}"
	do
		sendCmd "$cmd"
		sendCmd
	done
}

#exit
trap "cleanup;exit" INT TERM HUP

# currently runs only via 
coproc sqlplus -silent /nolog 
cpSTDOUT=${COPROC[0]}
cpSTDIN=${COPROC[1]}

# this readOutput may get a "SP2-0640: Not connected message"
# if there is a login.sql in SQLPATH or ORACLE_PATH, it may have tried to 
# do something that cannot yet be done, as coproc has not yet connected
readOutput

echo COPROC_PID: $COPROC_PID
ps -lp $COPROC_PID

#echo cpSTDOUT: $cpSTDOUT
#echo cpSTDIN: $cpSTDIN

debug "sendCmd: connect $coprocCreds"
echo "connect: $coprocCreds"
sendCmd "connect $coprocCreds"

debug "runSqlInit"
runSqlInit

debug  "sendCmd 'select sysdate from dual;'"
sendCmd 'select sysdate from dual;'
readOutput; readOutput

#echo dryRun: $dryRun
[[ $dryRun == 'Y' ]] && {
	cleanup
	exit
}

while :
do

	#read -p "$sqlPrompt" sqlcmd
	# trying to catch CTL-D, but read does not catch it for some reason
	#[[ $sqlcmd == $'\u0004' ]] && { sqlCmd='exit'; }

	#echo " sendCmd start $sqlplusScript"
	sendSql "start $sqlplusScript"
	sendCmd

	for outputLine in $(readOutput)
	do

		declare alertVal=$outputLine

		$(verbose) && {
			echo '==================='
			echo outputLine: $outputLine
			echo alertVal: $alertVal
		}

		declare sendAlert='N'

		if [[ $stringComparison == 'Y' ]]; then
			#echo "ALERTVAL: $alertVal"
			#echo "stringToCompare: $stringToCompare"
			[[ $alertVal =~ "$stringToCompare" ]] && { sendAlert='Y'; }
		else
			#[[ $alertVal -gt $alertThreshold ]] && { sendAlert='Y'; }
			# work with floats
			#echo alertVal: $alertVal
			#echo alertThreshold: $alertThreshold
			sendAlert=$(echo $alertVal $alertThreshold | perl -e 'chomp; my ($value,$threshold)=split(q(\s+),<STDIN>); print $value > $threshold ? q{Y} : q{N}')
		fi

		[[ "$sendAlert" == 'Y' ]] && {
			# run the sqlplus commands
			# capture the output for the email
			echo "Sending Alert!   ALERTVAL: $alertVal"

			declare emailFile=$(mktemp)
			echo $emailMsg > $emailFile

			for sqlcmd in "${sqlplusCmds[@]}"
			do
				
				# is this SQL or a cmd?
				# commands prefaced with 'SQL' or 'CMD'
				# sql scripts count as SQL
				declare cmdType=$(echo $sqlcmd | awk -F$cmdDelimiter '{ print $1 }')
				declare cmd=$(echo $sqlcmd | awk -F$cmdDelimiter '{ print $NF }')

				[[ $cmdType =~ ^(CMD|SQL)$ ]] || {
						warning "aborting - Invalid CMD Type of '$cmdType' encountered"
						cleanup
						# kill children
						jobs -p | xargs kill
						exit 1
				}

				# sleep for N seconds when coproc-sleep N found
				declare firstWord=$(echo $cmd | awk '{ print $1 }')
				if [[ $firstWord == 'coproc-sleep' ]]; then
					# the second word should be an integer
					declare sleepSeconds=$(echo $sqlcmd | awk '{ print $2 }')
			
					# abort if not an integer
					$(echo $sleepSeconds | grep -qE '^[[:digit:]]+$') || {
						warning "aborting - Invalid sleep value of '$sleepSeconds' encountered"
						cleanup
						# kill children
						jobs -p | xargs kill
						exit 1
					}

					sleep $sleepSeconds
			
				else
					if [[ $cmdType == 'SQL' ]]; then
						sendSql "$cmd"
					else
						sendCmd "$cmd"
					fi
					sendCmd
				fi

				results=$(readOutput;readOutput)
				echo "Results: $results"
				echo "$results" >> $emailFile
			done

			# reset the sql environment after running unknown sql scripts
			# this is vital for reading the alert output
			runSqlInit

			# email if there are addresses
			[[ ${#emailAddresses[@]} -gt 0 ]] && {
				cat $emailFile | mailx -s 'coproc-mon.sh alert' $emailAddressList		
			}
			rm -f $emailFile

			[[ $oneShotAlert == 'Y' ]] && {
				readOutput
				cleanup
				echo "exiting due to oneShotAlert flag"
				exit
			}

			echo Sleeping $postAlertSleepTime seconds until next check

			sleep $postAlertSleepTime
		}

		[[ -r "$exitFile" ]] && {
			cleanup
			exit
		}

		sleep $chkInterval

	done
done

wait




