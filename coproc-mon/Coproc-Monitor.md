
Coproc Monitor
==============


Goal: Create a monitor in Bash that can repeatedly check a condition in tight loop

Issue: I do not want to repeatedly login via sqlplus in that loop.

Requirements: Nothing can be installed to make this work. Only tools that normally exist on a Linux based Oracle database server can be used.

One way to accomplish this is by starting sqlplus as a Bash COPROC.

Doing so puts sqlplus in the background and bash provides 2 variables indicating the STDIN and SDTOUT file descriptors.

Here is an example:

$  coproc sqlplus -silent /nolog
[1] 5840

$  echo ${COPROC[0]}
63

$  echo ${COPROC[1]}
60
$  cpSTDOUT=${COPROC[0]}

$  cpSTDIN=${COPROC[1]}

echo 'connect /@ora192rac02/cdb.jks.com as sysdba' >&$cpSTDIN

Now we write to STDIN for sqlplus:
echo 'select distinct username from v$session where username is not null;' >&$cpSTDIN


Now read the output:

while read -r -t .1 -u "$cpSTDOUT" spout;  do echo "$spout"; done

USERNAME
---------------------------
SYS
SYSRAC
SOE


The '-t' argument to 'read' is there to timeout the read call if nothing is received within .1 seconds.

Without the '-t' argument, the loop will result in a non-blocking read that cannot be endded from the current session.
It will be necessary to kill the read from another terminal session.

For this example, that works well enough. However, what if the SQL does not return immediately?

The following function is used to simulate a long running SQL statement that we are using to monitor some database condition.


create or replace function sleep ( seconds_in number )
return number
is
begin
	dbms_lock.sleep(seconds_in);
	dbms_output.enable;
	dbms_output.put_line('slept for ' || to_char(seconds_in,'9990.09') );
	return seconds_in;
end;
/

show errors function sleep

Normally, a long running SQL would not be used for monitoring, but this is being used to demonstrate the problem with using sqlplus as a background process.

Also, some resulting scripts may be long running - such as the condition is found, and some report must be run.

For just the reporting purposes, sqlplus could be started within the monintoring loop, only when needed for reporting.

Now we will send the 'long running' query to sqlplus:

$ echo 'select sleep(120) from dual;'  >&$cpSTDIN

And now, try to read the output:

$  while read -r -t .1 -u "$cpSTDOUT" spout;  do echo "$spout"; done
$

And of course, there is nothing, as the query will not return for two minutes.

What can be done? 

The routine to collect the output could be run until something is found.

If I have a good idea of how long the query will take, a 'sleep N' could be used in the bash script prior to trying to read the output.

There are other possible solutions as well

* redirect sqlplus STDOUT and STDIN to named pipes
* using non-blocking reads on the pipes. 
** `dd bs=256 if='named pipe here' iflag=nonblock status=noxfer`

As you can see, making this work as I want is quite difficult in Bash.

Let's keep the goal in mind: a tight loop that logs in to the database only once.

This really is not a job for Bash. Doing this requires a programming language.

A requirement for this project is that no tools can be installed.

Fortunately, when Oracle is installed, it comes equipped with a language that can meet all of my requirements:  Perl.

Since at least Oracle 11.1, the DBI and DBD::Oracle modules have been included with the Perl installation, allowing easy connections to the database.

Whether you like Perl or not is irrelevant: it is a great tool for the job, and is installed in database ORACLE_HOME.

Let's consider a minimalist Perl script do demonstrate.

Assumptions:
* access to db server and oracle account
* logon is via Bequeath connection as SYSDBA to the current ORACLE_SID


=========================================================
use warnings;
use strict;
use DBI;
#use Data::Dumper;
use English;

$OUTPUT_AUTOFLUSH=1; # flush output immediately

my $dbh ;

$dbh = DBI->connect(
   'dbi:Oracle:',undef,undef,
   {
      RaiseError => 1,
      AutoCommit => 0,
      ora_session_mode => 2 # sysdba
   }
);

die "Connect to db failed \n" unless $dbh;
$dbh->{RowCacheSize} = 100;

my $sql=q{select user from dual};

# statement handle
my $sth = $dbh->prepare($sql,{ora_check_sql => 0});
$sth->execute;

# only 1 row
my ($dbuser) = $sth->fetchrow_array;
$sth->finish;

print "Username: $dbuser\n";

$dbh->disconnect;

=========================================================

Running the demo script:

  $ $ORACLE_HOME/perl/bin/perl ./connect-sysdba-demo.pl
  Username: SYS



Now let's make it do some work:





























