Load Monitors
=============

# Scripts used to watch for a trigger event and run a script

## xkffof-mon.sh

This is kind of a special one-off monitor.

In 12.1 ASM, the value for X$KFFOF.MAPID_KFFOF may grow excessively.

There is a patch for this, but if the db cannot be patched immediately, an ASM instance restart will suffice.

This script will monitor the growth of X$KFFOF.MAPID_KFFOF per file.

An alert is emailed if execessive growth is detected.

Usage:

```text
$  ./xkffof-mon.sh -h

Usage: ./xkffof-mon.sh

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
```

Additionaly, the data is stored in `csv/xkffof-mon.csv` for later use.

### Setup

Downloads the code from [load-monitors - cx branch](https://github.com/jkstill/load-monitors/tree/cx)

Be sure to get the cx branch.

Once downloaded, edit the following lines at the top of the `xkffof-mon.sh` script

```bash
# change as needed
declare NOTIFY_LIST='some-dba@yourdomain.com,another-dba@yourdomain.com'

# leave blank for connecting as '/ as sysasm' locally
declare ORA_USER=''
declare ORA_PASSWORD=''
declare ORA_CONNECT=''

declare ORA_USER='sys'
declare ORA_PASSWORD='password'
# the '@' is required
declare ORA_CONNECT='@someserver/+ASM'

# edit this location as needed
# load the functions
declare FUNCTIONS_FILE=/home/jkstill/oracle/dba/load-monitors/load-functions.sh; export FUNCTIONS_FILE
```

### Running

#### Test it first

Check every 5 seconds with a low threshold:

```text
./xkffof-mon.sh -c 5 -t 10
```

You probably will not see any output on the screen.

The will be a file `csv/xkffof-mon.csv`

If that is working, stop the script with CTL-C. 

Remove the file `csv/xkffof-mon.csv` if you like.

Now start it for real.

Here we are running with an interval of 1 hour, and a threshold growth value of 10000 for MAPID_KFFOF (same as default settings)

```text
$  nohup ./xkffof-mon.sh -c 3600 -t 10000 &
[1] 30359
$  nohup: ignoring input and appending output to 'nohup.out'

$  ls -l nohup.out
-rw------- 1 jkstill dba 0 2022-01-04 14:57 nohup.out

$  ls -l csv/xkffof-mon.csv
-rw-rw-r-- 1 jkstill dba 1749492 Jan  4 14:57 csv/xkffof-mon.csv

$  ps -p  30359 -o cmd
CMD
bash ./xkffof-mon.sh -c 3600 -t 10000

```

You should get an email in the event the growth threshold is exceeded.
(works in testing :)

## Capture Load 

Capture load average every 10 seconds.

### load_mon.sh

Capture StatsPack Snapshots during High Load

Load average is monitored 
During high load, three level 7 Statspack Snapshots are captured at two minute intervals.

### snap_mon.sh:

When load reaches threshold, run snapNmin.sql N times and exits
(see comments in script)
Adjust the parameters in the script as needed

### snapNmin.sql:

Creates two level 7 StatsPack snapshots, runs a report and saves to local dir


### snapper_mon.sh:

Captures Snapper report during high load

When load reaches threshold, run snapper a configurable number of times
This script is similar to snap_mon.sh, but runs snapper.sql rather than StatsPack.

Get current snapper.sql and snapper4.sql 

```text
wget http://blog.tanelpoder.com/files/scripts/snapper.sql
wget http://blog.tanelpoder.com/files/scripts/snapper4.sql
```

## Capture SQL Executions

Used when I suspect there are a large number of executions causing high loads during a short period of time.
These script will collect sql_id + executions from v$sqlstats
Call with sql_exec_mon.sh
Exits after approx 1 day of snapshots


### sql_exec_mon.sh

Capture SQL executions during high load

### create_sql_executions.sql

Create tables used by update_save_sqlstats.sql

update_save_sqlstats.sql: save sql exe stats

## Other stuff 

## get_bind_values.sql

Get bind values for a query

There are some other misc and possibly useful scripts

