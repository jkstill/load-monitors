#!/usr/bin/env bash

: <<'COMMENT'

this can return creds via whatever means required

in this case it just returns a login for an Oracle Autonomous database
where the username and password are stored in an auto-login wallet

COMMENT

#echo '/@atp21c'

echo '/@ora192rac02/cdb.jks.com as sysdba'


