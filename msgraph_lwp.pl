#! /usr/bin/perl

use strict;
use warnings;
use v5.10;

use Data::Dumper;
use Config::Simple;
use FindBin;
use POSIX qw(strftime);
use Getopt::Long;
use lib "$FindBin::Bin/lib";

use MsGroups;
use Logger;


my %config;
Config::Simple->import_from("$FindBin::Bin/groups.cfg",\%config) or die("No config: $!");

my $now = time();
my $ts = strftime('%Y-%m-%dT%H:%M:%S', localtime($now));


my $filter;
my $verbose;
my $no_owner;

GetOptions(
	"filter=s"	=>	\$filter,
	"verbose"	=>	\$verbose,
	"no_owner"	=>	\$no_owner,
) or die("Error in command line options: $!");

# Start of the logger
my $logger = Logger->new(
	'filename' => "$FindBin::Bin/Log/$FindBin::Script-$ts.log",
	'verbose' => $verbose
); 
$logger->make_log("$FindBin::Bin/$FindBin::Script started.");

if (@ARGV){
	$logger->make_log("ARGV is: ");
}else{
	$logger->make_log("No commandline options");
}

if ($filter){
	$logger->make_log("Filter is: $filter");
}
if ($verbose){
	$logger->make_log("Verbose is set.");
}
if ($no_owner){
	$logger->make_log("NoOwner is set.");
}

my $session = MsGroups->new(
	'app_id'         => $config{'APP_ID'},
	'app_secret'     => $config{'APP_SECRET'},
	'tenant_id'      => $config{'TENANT_ID'},
	'login_endpoint' => $config{'LOGIN_ENDPOINT'},
	'graph_endpoint' => $config{'GRAPH_ENDPOINT'},
	'blaat' => $config{'GRAPH_ENDPOINT'},
	'filter'         => $filter,
);

if ($session->_get_access_token){
	my $groups = $session->fetch_groups();
	my $count = scalar @$groups;
	$logger->make_log("$count groups fetched.");
	while (my ($i, $group) = each @{$groups}){
		$logger->make_log("$$group{'id'} => $$group{'displayName'}");
	}

	if ($no_owner){ # Geen idee waarom dit hier staat, is geen functionaliteit voor in de lib namelijk
		$groups = $session->fetch_groups_no_owner($groups);
		$count = scalar @$groups;
		$logger->make_log("$count Groups without owner.");
		while (my ($i, $group) = each @{$groups}){
			$logger->make_log("$$group{'id'} => $$group{'displayName'}");
		}
	}
}else{
	print "No token!\n";
}
# vim: set foldmethod=marker
