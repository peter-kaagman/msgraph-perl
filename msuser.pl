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

use MsUsers;
use Logger;


my %config;
Config::Simple->import_from("$FindBin::Bin/groups.cfg",\%config) or die("No config: $!");

my $now = time();
my $ts = strftime('%Y-%m-%dT%H:%M:%S', localtime($now));


my $user;
my $verbose;

GetOptions(
	"user=s"	=>	\$user,
	"verbose"	=>	\$verbose,
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

if ($verbose){
	$logger->make_log("Verbose is set.");
}

my $session = MsUser->new(
	'app_id'         => $config{'APP_ID'},
	'app_secret'     => $config{'APP_SECRET'},
	'tenant_id'      => $config{'TENANT_ID'},
	'login_endpoint' => $config{'LOGIN_ENDPOINT'},
	'graph_endpoint' => $config{'GRAPH_ENDPOINT'},
	'filter'         => "\$filter=onPremisesSamAccountName eq '$user'",
	'select'         => '\$select=id,userPrincipalName,onPremisesSamAccountName',
);

if ($session->_get_access_token){
	my $users = $session->users_fetch(1);
	if (@{$users}){
		my $user_info = $users->[0];
		$logger->make_log("$user fetched.");
		$logger->make_log("userPrincipalName: ".$user_info->{'userPrincipalName'});
	}else{
		$logger->make_log("No user found for samAccountName: $user");
	}
}else{
	print "No token!\n";
}
# vim: set foldmethod=marker
