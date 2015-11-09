
-- update_save_sqlstats.sql

-- save sql stats for looking up sqlid in sql_executions

merge into save_sqlstats ss
   using v$sqlstats vs
   on ( ss.sql_id = vs.sql_id )
when matched then
  update set 
     ss.last_active_time   = vs.last_active_time
   , ss.last_active_child_address   = vs.last_active_child_address
   , ss.parse_calls   = vs.parse_calls
   , ss.disk_reads   = vs.disk_reads
   , ss.direct_writes   = vs.direct_writes
   , ss.buffer_gets   = vs.buffer_gets
   , ss.rows_processed   = vs.rows_processed
   , ss.serializable_aborts   = vs.serializable_aborts
   , ss.fetches   = vs.fetches
   , ss.executions   = vs.executions
   , ss.end_of_fetch_count   = vs.end_of_fetch_count
   , ss.loads   = vs.loads
   , ss.version_count   = vs.version_count
   , ss.invalidations   = vs.invalidations
   , ss.px_servers_executions   = vs.px_servers_executions
   , ss.cpu_time   = vs.cpu_time
   , ss.elapsed_time   = vs.elapsed_time
   , ss.avg_hard_parse_time   = vs.avg_hard_parse_time
   , ss.application_wait_time   = vs.application_wait_time
   , ss.concurrency_wait_time   = vs.concurrency_wait_time
   , ss.cluster_wait_time   = vs.cluster_wait_time
   , ss.user_io_wait_time   = vs.user_io_wait_time
   , ss.plsql_exec_time   = vs.plsql_exec_time
   , ss.java_exec_time   = vs.java_exec_time
   , ss.sorts   = vs.sorts
   , ss.sharable_mem   = vs.sharable_mem
   , ss.total_sharable_mem   = vs.total_sharable_mem
   , ss.typecheck_mem   = vs.typecheck_mem
when not matched then
   insert 
   (
      ss.sql_text , ss.sql_fulltext , ss.sql_id , ss.last_active_time , ss.last_active_child_address
      , ss.plan_hash_value , ss.parse_calls , ss.disk_reads , ss.direct_writes , ss.buffer_gets
      , ss.rows_processed , ss.serializable_aborts , ss.fetches , ss.executions , ss.end_of_fetch_count
      , ss.loads , ss.version_count , ss.invalidations , ss.px_servers_executions , ss.cpu_time
      , ss.elapsed_time , ss.avg_hard_parse_time , ss.application_wait_time , ss.concurrency_wait_time , ss.cluster_wait_time
      , ss.user_io_wait_time , ss.plsql_exec_time , ss.java_exec_time , ss.sorts , ss.sharable_mem
      , ss.total_sharable_mem , ss.typecheck_mem
   )
   values
   (
      vs.sql_text , vs.sql_fulltext , vs.sql_id , vs.last_active_time , vs.last_active_child_address
      , vs.plan_hash_value , vs.parse_calls , vs.disk_reads , vs.direct_writes , vs.buffer_gets
      , vs.rows_processed , vs.serializable_aborts , vs.fetches , vs.executions , vs.end_of_fetch_count
      , vs.loads , vs.version_count , vs.invalidations , vs.px_servers_executions , vs.cpu_time
      , vs.elapsed_time , vs.avg_hard_parse_time , vs.application_wait_time , vs.concurrency_wait_time , vs.cluster_wait_time
      , vs.user_io_wait_time , vs.plsql_exec_time , vs.java_exec_time , vs.sorts , vs.sharable_mem
      , vs.total_sharable_mem , vs.typecheck_mem
   )
/

