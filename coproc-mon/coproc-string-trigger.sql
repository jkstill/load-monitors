with data as (
	select
		distinct username
		, count(*) over (partition by username) sesscount
	from v$session
	where username is not null
)
select username || chr(10) username
from data 
where sesscount > 2;
