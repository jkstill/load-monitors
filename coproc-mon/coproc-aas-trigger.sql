select 
	--s.metric_name,
	--g.name,
	s.value 
from v$sysmetric  s, v$metricgroup g
where s.metric_name = 'Average Active Sessions'
	and g.group_id = s.group_id
	--and g.name = 'System Metrics Long Duration'
	-- looking for spikes
	and g.name = 'System Metrics Short Duration'
/

