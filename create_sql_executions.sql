
-- drop table sql_executions;

create table sql_executions
as 
select sql_id, executions, sysdate timestamp, 1.1 load_avg
from v$sqlstats
where 1=0
/


create table save_sqlstats
as
select *
from v$sqlstats
where rownum <= 100
/



