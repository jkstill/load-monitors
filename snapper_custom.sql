
set pause off
set echo off
set timing off
set trimspool on
set feed on term on echo off verify off
set line 200
set pagesize 0 heading off

clear col
clear break
clear computes

btitle ''
ttitle ''

btitle off
ttitle off

set newpage 1

col snap_duration new_value snap_duration noprint

prompt "Duration for snapper? "
set term off feed off
select '&1' snap_duration from dual;
set term on feed on

undef 1

alter session set tracefile_identifier='SNAPPER';

-- Snapper v4 supports RAC and requires Oracle 10.1 or a newer DB version.
-- Snapper v3.5 works on Oracle versions starting from Oracle 9.2 (no RAC support)

-- Single instance < 10g
--@snapper all,trace &snap_duration 1 "select sid from v$session where status = 'ACTIVE' and state = 'WAITING' and type = 'USER'"

-- RAC or single instance, 10g+
@snapper4 all,trace &snap_duration 1 "select inst_id,sid from gv$session where status = 'ACTIVE' and state = 'WAITING' and type = 'USER'"


