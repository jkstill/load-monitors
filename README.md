
Scripts used to watch for a trigger event and run a script

<h3> Capture Load </h3>

Capture load average every 10 seconds.

load_mon.sh:


<h3> Capture StatsPack Snapshots during High Load </h3>

Load average is monitored 
During high load, three level 7 Statspack Snapshots are captured at two minute intervals.

snap_mon.sh:
When load reaches threshold, run snapNmin.sql N times and exits
(see comments in script)
Adjust the parameters in the script as needed

snapNmin.sql:
Creates two level 7 StatsPack snapshots, runs a report and saves to local dir


<h3> Captures Snapper report during high load </h3>

snapper_mon.sh:
When load reaches threshold, run snapper a configurable number of times
This script is similar to snap_mon.sh, but runs snapper.sql rather than StatsPack.

Get current snapper.sql and snapper4.sql 

<pre>
wget http://blog.tanelpoder.com/files/scripts/snapper.sql
wget http://blog.tanelpoder.com/files/scripts/snapper4.sql
</pre>

<h3> Capture SQL Executions for Avail </h3>

sql_exec_mon.sh: Capture SQL executions during high load

create_sql_executions.sql: Create tables used by update_save_sqlstats.sql

update_save_sqlstats.sql: save sql exe stats

<h3> Other stuff </h3>

get_bind_values.sql: get bind values for a query

There are some other misc and possibly useful scripts

