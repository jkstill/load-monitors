#!/usr/bin/env bash

pidFile='/tmp/pidtest.pid'

getPidLockFile () {
	echo $pidFile
}


cleanup () {
	rm -f $(getPidLockFile)
}

pidLock () {

	local PID=$$
	echo "======================"
	echo current PID: $PID
	local myScriptName=$(basename $0)
	
	# does log file exist?
	local lockFileExists=Y

	[[ -r $(getPidLockFile) ]] || { lockFileExists=N; }

	if [[ $lockFileExists == 'Y' ]]; then
		echo LockFile Exists
		local testPID
		mapfile -t -n 1 testPID < <(cat $(getPidLockFile))
		# re-use the file if the pid does not exist
		# or if the pid exists, but is not this script

		pidExe=$(ps -p $testPID -o cmd -h)

		echo testPID: $testPID
		echo pidExe: $pidExe
		echo myScriptName: $myScriptName

		if [ -n "$pidExe" ];  then  # something running on this PID if not blank
			# if it is this script running
			echo pidExe is non-blank
			if $(echo "$pidExe" | grep -hq "$myScriptName"); then
				echo pidExe: $pidExe
				echo myScriptName: $myScriptName
				echo "already running $myScriptName with PID: $testPID"
				ps -p $testPID -o user,pid,cmd,
				exit 2
				# if something running on this pid, but not this script
			fi
		fi

		# must be a dead pid, or another process that got the same ID as previous execution of this script

	fi

	echo $$ > $(getPidLockFile)

}

test () {
	echo "basename: " $(basename $0)
}

pidLock

test


sleep 3600

