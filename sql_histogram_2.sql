with my_sql_exec as (
	select *
	from sql_executions_hiload_2
	where executions > 1000
)
, sqlsum as (
	select sum(executions) executions
	from sql_executions_hiload_2
)
select s2.sql_id, s2.executions,
	substr(lpad('@',100,'@'), 1, s2.executions / s.executions * 100 ) histrogram
from my_sql_exec s2
, sqlsum s
order by executions
/
