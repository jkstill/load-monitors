
set pagesize 50000
set linesize 200

with sqlexec as (
	select to_date(to_char(timestamp,'yyyy-mm-dd hh24'),'yyyy-mm-dd hh24') timestamp
		, sql_id
		, executions
	from sql_executions
	where sql_id != '0'
),
sqlcount as (
	select sum(executions) sqlcount
	from sqlexec
),
exec_hist as (
	select 
		timestamp
		, sum(executions) exec_sum
	from sqlexec
	group by timestamp
)
select 
	e.timestamp
	, e.exec_sum
	, substr(lpad('@',100,'@'), 1, e.exec_sum / s.sqlcount * 100 ) histrogram
from exec_hist e
, sqlcount s
/
