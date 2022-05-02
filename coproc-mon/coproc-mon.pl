#!/usr/bin/env perl

use warnings;
use strict;
use DBI;
use Getopt::Long;
use Data::Dumper;


$|=1; # flush output immediately

my $dbh ;

$dbh = DBI->connect(
	'dbi:Oracle:',undef,undef,
	{
		RaiseError => 1,
		AutoCommit => 0,
		ora_session_mode => 2
	}
);
die "Connect to  $db failed \n" unless $dbh;
$dbh->{RowCacheSize} = 100;

$dbh->disconnect;

my $sql=q{select user from dual};
my $sth = $dbh->prepare($sql,{ora_check_sql => 0});
$sth->execute;
my ($dbuser) = $sth->fetchrow_array;
$sth->finish;

print "Username: $dbuser\n";

$dbh->disconnect;

sub usage {
	my $exitVal = shift;
	$exitVal = 0 unless defined $exitVal;
	use File::Basename;
	my $basename = basename($0);
	print qq/

usage: $basename

  -database      target instance
  -username      target instance account name
  -password      target instance account password
  -sysdba        logon as sysdba
  -sysoper       logon as sysoper
  -local-sysdba  logon to local instance as sysdba. ORACLE_SID must be set
                 the following options will be ignored:
                   -database
                   -username
                   -password

  example:

  $basename -database dv07 -username scott -password tiger -sysdba  

  $basename -local-sysdba 

/;
   exit $exitVal;
};



