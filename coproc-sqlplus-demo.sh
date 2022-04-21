#!/usr/bin/env bash


DEBUG=N

declare coprocCreds=$(./coproc-creds.sh)
declare sqlPrompt='SQL-CoProc# '

echo "coprocCreds: $coprocCreds"


declare readTimeOut=1

debug () {
	local msg="$@"
	[[ $DEBUG == 'Y' ]] || { return 0; }
	echo "##############################################"
	echo "## $msg"
	echo "##############################################"
	return 0
}

warning () {
	local msg="$@"
	echo "==="
	echo "=== Warning:"
	echo "=== $msg"
	echo "==="
}

readOutput () {

	#while TMOUT=$readTimeOut read output <&"$cpSTDOUT"
	while read -t $readTimeOut output <&"$cpSTDOUT"
	do
		[[ $? -gt 128 ]] && { warning "timed out getting output"; }
		echo "$output"
	done

}

sendCmd () {
	local cmd="$@"
	debug "sending command '$cmd'"

	[[ $DEBUG == 'Y' ]] && {
		echo "sqlcmd hexdump:"
		echo $sqlcmd | hexdump -C
	}

	echo "$cmd" >&"$cpSTDIN"
	echo "" >&"$cpSTDIN"
}


#coproc echo "connect $coprocCreds" | sqlplus -silent /nolog 
coproc sqlplus -silent /nolog 
coprocPID=$!
echo coprocPID: $coprocPID

ps -lp $coprocPID

cpSTDOUT=${COPROC[0]}
cpSTDIN=${COPROC[1]}

sendCmd "connect $coprocCreds"
sendCmd 'select sysdate from dual;'

#echo cpSTDOUT: $cpSTDOUT
#echo cpSTDIN: $cpSTDIN

sendCmd 'set tab off'
readOutput
sendCmd '@who2.sql' 
sendCmd

readOutput

while :
do
	read -p "$sqlPrompt" sqlcmd
	# trying to catch CTL-D, but read does not catch it for some reason
	[[ $sqlcmd == $'\u0004' ]] && { sqlCmd='exit'; }

	sendCmd "$sqlcmd"
	sendCmd
	readOutput

	[[ $sqlcmd == 'exit' ]] && { break; }

done

wait




