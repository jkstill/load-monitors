
set pagesize 60
set term off feed on echo off verify off

set linesize 200 trimspool on

break on timestamp 

spool sql_executions.log

with hiload as (
	select timestamp, sql_id, load_avg, executions - lag(executions,1) over (order by sql_id,timestamp) executions
	from sql_executions
	--where sql_id in ('g2xsjrnpvt48n','1gcpf57uf408w')
	order by timestamp,sql_id
)
select timestamp, sql_id, load_avg, executions
from hiload
where load_avg >= 30 
	and executions > 100
order by timestamp,sql_id
/

spool off

set term on

ed sql_executions.log

