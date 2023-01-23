#! /usr/bin/perl -W

use strict;
use Data::Dumper;
use JSON;
use Config::Simple;
use FindBin;
#use lib "$FindBin::Bin/../lib";
use LWP::UserAgent;

my %config;
Config::Simple->import_from("$FindBin::Bin/groups.cfg",\%config) or die("No config: $!");

my $ua = LWP::UserAgent->new(
	'send_te' => '0',
);

sub login_app { #	{{{1
	my $url = "$config{'LOGIN_ENDPOINT'}/$config{'TENANT_ID'}/oauth2/token";
	my $r = HTTP::Request->new(
		'POST' => $url,
			[
				'Accept'		=>	'*/*',
				'User-Agent'	=>	'curl/7.55.1',
				'Content-Type'	=>	'application/x-www-form-urlencoded'
			],
			"grant_type=client_credentials&client_id=$config{'APP_ID'}&client_secret=$config{'APP_PASS'}&scope=$config{'GRAPH_ENDPOINT'}/.default&resource=$config{'GRAPH_ENDPOINT'}"
	);

	my $result = $ua->request($r);

	if ($result->is_success){
		return decode_json($result->decoded_content)
	}else{
		print Dumper $result;
		die $result->status_line;
	}
	
}#	}}}

sub fetch { #	{{{1
	my $token = shift;
	my $url = shift;
	my $r  = HTTP::Request->new(
    	'GET' => $url,
			[
        		'Accept'        => '*/*',
        		'Authorization' => "Bearer $token",
        		'User-Agent'    => 'curl/7.55.1',
        		'Content-Type'  => 'application/json'
			],
	);	
	my $result = $ua->request($r);
	if ($result->is_success){
		return decode_json($result->decoded_content)
	}else{
		print Dumper $result;
		die $result->status_line;
	}
	
}#	}}}

my $token_request = login_app();
print Dumper $token_request;

if ($$token_request{'access_token'}){
	my $url = "$config{'GRAPH_ENDPOINT'}/v1.0/groups";
	my $groups = fetch($$token_request{'access_token'}, $url);
	print Dumper $groups;
}
