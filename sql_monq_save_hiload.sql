create table sql_executions_hiload_2
as
with hiload as (
	select timestamp, sql_id, load_avg, executions - lag(executions,1) over (order by sql_id,timestamp) executions
	from sql_executions
	--where sql_id in ('g2xsjrnpvt48n','1gcpf57uf408w')
	order by timestamp,sql_id
)
select timestamp, sql_id, load_avg, executions
from hiload
where load_avg >= 8
	and executions > 10
/
