select timestamp, sql_id, load_avg, executions - lag(executions,1) over (order by sql_id,timestamp) executions
from stest
where sql_id in ('g2xsjrnpvt48n','1gcpf57uf408w')
order by timestamp,sql_id
/
