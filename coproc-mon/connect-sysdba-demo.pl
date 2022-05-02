#!/usr/bin/env perl

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



