
select floor(value) aas
from V$SYSMETRIC
where  metric_id = 2147
	and group_id = 2 -- long duration
	--and group_id = 3 -- short duration
/
