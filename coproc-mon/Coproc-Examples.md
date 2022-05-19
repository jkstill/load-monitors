
Note: 'not connected' messages indicate a bug in the script

## load avg trigger

Get the current OS load average from Oracle.

Send an alert if the value is > 1

Runs only once due to '-o'

```text
./coproc-mon.sh -o -a 1 -c 1 -r .5 -t .1 -s coproc-loadavg-trigger.sql

processing mail from coproc-email.txt
COPROC_PID: 4938
F S   UID   PID  PPID  C PRI  NI ADDR SZ WCHAN  TTY          TIME CMD
0 S  1000  4938  4899  0  80   0 - 23629 pipe_w pts/14   00:00:00 sqlplus
SP2-0640: Not connected

Session altered.

05/18/2022 16:58:20
Sending Alert!   ALERTVAL: .659179688
Results:
V_OVERSION_MAJOR
--------------------------------------------------------------------------------
19

1 row selected.


PL/SQL procedure successfully completed.


                                                                BLOCK                                      SRVR                       CLIENT
USERNAME      SID SERIAL# SQL ID           PID STATUS         CHANGES MACHINE                   OSUSER     PID   CLIENT PROGRAM       PID           LOGON TIME        IDLE TIME
---------- ------ ------- ------------- ------ ---------- ----------- ------------------------- ---------- ----- -------------------- ------------- ----------------- -----------
SOE            33   50359 g81cbrq5yamf5    112 ACTIVE             174 swingbench-cli-01.jks.com jkstill    21618 JDBC Thin Client     1234          05/18/22 16:52:55 00:00:00:51
              424   52841 7t0959msvyt5g     97 ACTIVE             147 swingbench-cli-01.jks.com jkstill    16601 JDBC Thin Client     1234          05/18/22 16:40:51 00:00:07:08
              427   62562 8zz6y2yzdqjp0    117 ACTIVE             192 swingbench-cli-01.jks.com jkstill    21622 JDBC Thin Client     1234          05/18/22 16:52:55 00:00:00:25
              780   21580 7t0959msvyt5g     98 ACTIVE             132 swingbench-cli-01.jks.com jkstill    16603 JDBC Thin Client     1234          05/18/22 16:40:51 00:00:06:01
              781   14793 g81cbrq5yamf5    114 ACTIVE             219 swingbench-cli-01.jks.com jkstill    21620 JDBC Thin Client     1234          05/18/22 16:52:55 00:00:00:47
              806    5341 7t0959msvyt5g    110 ACTIVE             251 swingbench-cli-01.jks.com jkstill    21616 JDBC Thin Client     1234          05/18/22 16:52:55 00:00:01:52
             1158   10412 56pwkjspvmg3h    107 ACTIVE             347 swingbench-cli-01.jks.com jkstill    16605 JDBC Thin Client     1234          05/18/22 16:40:51 00:00:05:32

SYS           384   26205                   13 ACTIVE               0 ora192rac02.jks.com       oracle     1104  oracle@ora192rac02.j 1104_1112     05/05/22 23:53:37 12:17:04:43
              428   59235 4buuxuusf3muk     57 ACTIVE               0 poirot.jks.com            jkstill    23879 sqlplus@poirot.jks.c 4938          05/18/22 16:58:19 00:00:00:00
              801   36585                   86 INACTIVE             0 poirot.jks.com            jkstill    16961 sqlplus@poirot.jks.c 29916         05/18/22 16:41:48 00:00:11:20

SYSRAC         25   65489 7jycxu86n60qh    104 INACTIVE             0 ora192rac02.jks.com       oracle     2128  oraagent.bin@ora192r 859           05/05/22 23:54:05 12:17:04:15
              406   36005                  105 INACTIVE             0 ora192rac02.jks.com       oracle     24947 oraagent.bin@ora192r 859           05/12/22 06:35:53 00:00:00:05
              412   40466                  113 INACTIVE             0 ora192rac02.jks.com       oracle     2226  oraagent.bin@ora192r 859           05/05/22 23:54:06 04:20:01:23
              779   53106 7jycxu86n60qh     58 INACTIVE             0 ora192rac02.jks.com       oracle     2120  oraagent.bin@ora192r 859           05/05/22 23:54:05 12:17:04:15
              803   24508 1jbbrvuwc11zr     62 INACTIVE            54 ora192rac02.jks.com       oracle     31727 oraagent.bin@ora192r 859           05/13/22 20:52:27 04:20:05:29
             1173     633                  111 INACTIVE             0 ora192rac02.jks.com       oracle     2211  oraagent.bin@ora192r 859           05/05/22 23:54:06 12:17:04:14


16 rows selected.
Results: poirot.jks.com
Results: Wed May 18 16:58:22 PDT 2022
Results: 1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:81:0f:5a brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.254/24 brd 192.168.1.255 scope global noprefixroute enp0s3
       valid_lft forever preferred_lft forever
    inet6 fe80::e031:6d65:4764:2634/64 scope link noprefixroute
       valid_lft forever preferred_lft forever
3: docker0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN group default
    link/ether 02:42:07:02:cf:e0 brd ff:ff:ff:ff:ff:ff
    inet 172.17.0.1/16 brd 172.17.255.255 scope global docker0
       valid_lft forever preferred_lft forever
Results: Sampling SID select inst_id,sid from gv$session where status = 'ACTIVE' and state = 'WAITING' and type = 'USER' with interval 10 seconds, taking 1 snapshots...
Results:
-- Session Snapper v4.33 - by Tanel Poder ( https://tanelpoder.com/snapper ) - Enjoy the Most Advanced Oracle Troubleshooting Script on the Planet! :)


---------------------------------------------------------------------------------------------------------------
  ActSes   %Thread | INST | SQL_ID          | SQL_CHILD | EVENT                               | WAIT_CLASS
---------------------------------------------------------------------------------------------------------------
    2.35    (235%) |    2 | g81cbrq5yamf5   | 0         | direct path read                    | User I/O
    1.47    (147%) |    2 | 7t0959msvyt5g   | 0         | read by other session               | User I/O
    1.00    (100%) |    2 | 56pwkjspvmg3h   | 0         | read by other session               | User I/O
     .94     (94%) |    2 | 8zz6y2yzdqjp0   | 0         | direct path read                    | User I/O
     .53     (53%) |    2 | 7t0959msvyt5g   | 0         | db file sequential read             | User I/O
     .47     (47%) |    2 | 7t0959msvyt5g   | 0         | db file scattered read              | User I/O
     .18     (18%) |    2 | 5ckxyqfvu60pj   | 0         | db file sequential read             | User I/O
     .06      (6%) |    2 | 8zz6y2yzdqjp0   | 0         | ON CPU                              | ON CPU

--  End of ASH snap 1, end=2022-05-18 16:58:34, seconds=10, samples_taken=17, AAS=7


PL/SQL procedure successfully completed.
exiting due to oneShotAlert flag

```

# Average Active Sessions trigger

Get the current short term AAS from Oracle.

Send an alert iit the value is > 1.

Runs only once due to '-o'

```text
./coproc-mon.sh  -o -a 1 -c 1 -r .1 -t 2.2 -s coproc-aas-trigger.sql

processing mail from coproc-email.txt
COPROC_PID: 4554
F S   UID   PID  PPID  C PRI  NI ADDR SZ WCHAN  TTY          TIME CMD
0 R  1000  4554  4503  0  80   0 - 23191 -      pts/14   00:00:00 sqlplus
SP2-0640: Not connected

Session altered.

05/18/2022 16:56:52
Sending Alert!   ALERTVAL: 6.61705658
Results:
V_OVERSION_MAJOR
--------------------------------------------------------------------------------
19

1 row selected.


PL/SQL procedure successfully completed.


                                                                BLOCK                                      SRVR                       CLIENT
USERNAME      SID SERIAL# SQL ID           PID STATUS         CHANGES MACHINE                   OSUSER     PID   CLIENT PROGRAM       PID           LOGON TIME        IDLE TIME
---------- ------ ------- ------------- ------ ---------- ----------- ------------------------- ---------- ----- -------------------- ------------- ----------------- -----------
SOE            33   50359 7ws837zynp1zv    112 ACTIVE              68 swingbench-cli-01.jks.com jkstill    21618 JDBC Thin Client     1234          05/18/22 16:52:55 00:00:00:28
              424   52841 7t0959msvyt5g     97 ACTIVE             147 swingbench-cli-01.jks.com jkstill    16601 JDBC Thin Client     1234          05/18/22 16:40:51 00:00:05:40
              427   62562 7hk2m2702ua0g    117 ACTIVE             192 swingbench-cli-01.jks.com jkstill    21622 JDBC Thin Client     1234          05/18/22 16:52:55 00:00:00:59
              780   21580 7t0959msvyt5g     98 ACTIVE             132 swingbench-cli-01.jks.com jkstill    16603 JDBC Thin Client     1234          05/18/22 16:40:51 00:00:04:33
              781   14793 7ws837zynp1zv    114 ACTIVE             101 swingbench-cli-01.jks.com jkstill    21620 JDBC Thin Client     1234          05/18/22 16:52:55 00:00:00:29
              806    5341 7t0959msvyt5g    110 ACTIVE             251 swingbench-cli-01.jks.com jkstill    21616 JDBC Thin Client     1234          05/18/22 16:52:55 00:00:00:24
             1158   10412 56pwkjspvmg3h    107 ACTIVE             347 swingbench-cli-01.jks.com jkstill    16605 JDBC Thin Client     1234          05/18/22 16:40:51 00:00:04:04

SYS           384   26205                   13 ACTIVE               0 ora192rac02.jks.com       oracle     1104  oracle@ora192rac02.j 1104_1112     05/05/22 23:53:37 12:17:03:15
              428   16829 4buuxuusf3muk     57 ACTIVE               0 poirot.jks.com            jkstill    23271 sqlplus@poirot.jks.c 4554          05/18/22 16:56:52 00:00:00:00
              801   36585                   86 INACTIVE             0 poirot.jks.com            jkstill    16961 sqlplus@poirot.jks.c 29916         05/18/22 16:41:48 00:00:09:52

SYSRAC         25   65489 7jycxu86n60qh    104 INACTIVE             0 ora192rac02.jks.com       oracle     2128  oraagent.bin@ora192r 859           05/05/22 23:54:05 12:17:02:47
              406   36005                  105 INACTIVE             0 ora192rac02.jks.com       oracle     24947 oraagent.bin@ora192r 859           05/12/22 06:35:53 00:00:00:07
              412   40466                  113 INACTIVE             0 ora192rac02.jks.com       oracle     2226  oraagent.bin@ora192r 859           05/05/22 23:54:06 04:19:59:55
              779   53106 7jycxu86n60qh     58 INACTIVE             0 ora192rac02.jks.com       oracle     2120  oraagent.bin@ora192r 859           05/05/22 23:54:05 12:17:02:47
              803   24508 1jbbrvuwc11zr     62 INACTIVE            54 ora192rac02.jks.com       oracle     31727 oraagent.bin@ora192r 859           05/13/22 20:52:27 04:20:04:01
             1173     633                  111 INACTIVE             0 ora192rac02.jks.com       oracle     2211  oraagent.bin@ora192r 859           05/05/22 23:54:06 12:17:02:46


16 rows selected.
Results: poirot.jks.com
Results: Wed May 18 16:56:52 PDT 2022
Results: 1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:81:0f:5a brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.254/24 brd 192.168.1.255 scope global noprefixroute enp0s3
       valid_lft forever preferred_lft forever
    inet6 fe80::e031:6d65:4764:2634/64 scope link noprefixroute
       valid_lft forever preferred_lft forever
3: docker0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN group default
    link/ether 02:42:07:02:cf:e0 brd ff:ff:ff:ff:ff:ff
    inet 172.17.0.1/16 brd 172.17.255.255 scope global docker0
       valid_lft forever preferred_lft forever
Results: Sampling SID select inst_id,sid from gv$session where status = 'ACTIVE' and state = 'WAITING' and type = 'USER' with interval 10 seconds, taking 1 snapshots...
Results:
-- Session Snapper v4.33 - by Tanel Poder ( https://tanelpoder.com/snapper ) - Enjoy the Most Advanced Oracle Troubleshooting Script on the Planet! :)


---------------------------------------------------------------------------------------------------------------
  ActSes   %Thread | INST | SQL_ID          | SQL_CHILD | EVENT                               | WAIT_CLASS
---------------------------------------------------------------------------------------------------------------
    2.25    (225%) |    2 | 7t0959msvyt5g   | 0         | read by other session               | User I/O
    1.00    (100%) |    2 | 7hk2m2702ua0g   | 1         | read by other session               | User I/O
    1.00    (100%) |    2 | 7ws837zynp1zv   | 0         | direct path read                    | User I/O
     .81     (81%) |    2 | 56pwkjspvmg3h   | 0         | read by other session               | User I/O
     .69     (69%) |    2 | g81cbrq5yamf5   | 0         | direct path read                    | User I/O
     .44     (44%) |    2 | 7t0959msvyt5g   | 0         | db file sequential read             | User I/O
     .25     (25%) |    2 | 7t0959msvyt5g   | 0         | db file scattered read              | User I/O
     .13     (13%) |    2 | 56pwkjspvmg3h   | 0         | db file scattered read              | User I/O
     .06      (6%) |    2 | g81cbrq5yamf5   | 0         | ON CPU                              | ON CPU
     .06      (6%) |    2 | 56pwkjspvmg3h   | 0         | db file sequential read             | User I/O

--  End of ASH snap 1, end=2022-05-18 16:57:03, seconds=10, samples_taken=16, AAS=6.8


PL/SQL procedure successfully completed.
exiting due to oneShotAlert flag

```


## misc examples

```text
./coproc-mon.sh -T 20
./coproc-mon.sh -T 20 -v -c 15  -s aas.sql 
./coproc-mon.sh -T 20 -v -c 15  -s aas.sql -n
./coproc-mon.sh -T 7 -v -c 5  -N
./coproc-mon.sh -T 7 -v -c 5  -R
./coproc-mon.sh -T 7 -v -c 5  -X
./coproc-mon.sh -T 7 -v -c 5  -x
./coproc-mon.sh -c 0 -r 0 -T 40 -v -s aas.sql 
./coproc-mon.sh -c 0 -r 0.1 -T 40 -v -s aas.sql 
./coproc-mon.sh -c 0.2 -r 0.2 -T 40 -v -s aas.sql 
./coproc-mon.sh -c 02 -r 0 -T 40 -v -s aas.sql 
./coproc-mon.sh -c 1  -i 'SWINGBENCH' -s coproc-string-trigger.sql -n
./coproc-mon.sh -c 1 -r 0.1 -i 'SOE' -m coproc-no-commands.txt -s coproc-string-trigger.sql  
./coproc-mon.sh -c 1 -r 0.1 -i 'SOE' -m coproc-no-commands.txt -s coproc-string-trigger.sql  -O
./coproc-mon.sh -c 1 -r 0.1 -i 'SOE' -m coproc-no-commands.txt -s coproc-string-trigger.sql -a 10
./coproc-mon.sh -c 1 -r 0.1 -i 'SOE' -m coproc-no-commands.txt -s coproc-string-trigger.sql -o -a 10
./coproc-mon.sh -c 1 -r 0.1 -i 'SOE' -m no-commands.txt -s coproc-string-trigger.sql  
./coproc-mon.sh -c 1 -r 0.1 -i 'SOE' -m no-commands.txt -s coproc-string-trigger.sql  -n
./coproc-mon.sh -c 1 -r 0.1 -i 'SWINGBENCH' -s coproc-string-trigger.sql 
./coproc-mon.sh -c 1 -r 0.1 -i 'SWINGBENCH' -s coproc-string-trigger.sql -n
./coproc-mon.sh -c 1 -r 0.1 -i 'SWINGBENCH' -v -s coproc-string-trigger.sql -n
./coproc-mon.sh -c 1 -r 0.25 -i 'SOE' -m no-commands.txt -s coproc-string-trigger.sql 
./coproc-mon.sh -c 1 -r 0.25 -i 'SOE' -s coproc-string-trigger.sql 
./coproc-mon.sh -c 1 -r 0.25 -i 'SWINGBENCH' -s coproc-string-trigger.sql 
./coproc-mon.sh -c 1 -r 0.25 -i 'SWINGBENCH' -s coproc-string-trigger.sql -n
./coproc-mon.sh -c 5 -r 0 -i 'SWINGBENCH' -v -s coproc-string-trigger.sql
./coproc-mon.sh -c 5 -r 0 -i 'SWINGBENCH' -v -s coproc-string-trigger.sqlx
./coproc-mon.sh -d -c 1 -r 0.25 -i 'SWINGBENCH' -s coproc-string-trigger.sql 
./coproc-mon.sh -o -c 1 -r 0.1 -i 'SOE' -m coproc-no-commands.txt -s coproc-string-trigger.sql -a 10
./coproc-mon.sh -r 0.2 -T 40 -v -c 1  -s aas.sql 
./coproc-mon.sh -t testing -r 1t2
```

