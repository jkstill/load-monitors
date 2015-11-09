
set pagesize 50000
set long 100000

with my_sql_exec as (
	select *
	from sql_executions_hiload_2
	where executions > 1000
),
sql_ids as (
	select distinct s.sql_id
	from save_sqlstats s
	join my_sql_exec m on m.sql_id = s.sql_id
)
select s.sql_id, executions, sql_fulltext
from sql_ids s
join save_sqlstats ss on ss.sql_id = s.sql_id
/
