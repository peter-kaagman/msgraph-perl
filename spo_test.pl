#! /usr/bin/env perl

use strict;
use warnings;
use v5.11;

use utf8;
use Data::Dumper;
use Config::Simple;
use DBI;
use Time::Piece;
use Parallel::ForkManager;
use FindBin;
use lib "$FindBin::Bin/lib";

use MsSpoList;

my %config;
Config::Simple->import_from("$FindBin::Bin/spo.cfg",\%config) or die("No config: $!");

my $spo_object = MsSpoList->new(
	'app_id'        => $config{'APP_ID'},
	'app_secret'    => $config{'APP_PASS'},
	'tenant_id'     => $config{'TENANT_ID'},
	'site_naam'     => 'support',
	'list_naam'     => 'ITSM360_Tickets',
	'login_endpoint'=> $config{'LOGIN_ENDPOINT'},
	'graph_endpoint'=> $config{'GRAPH_ENDPOINT'},
);


my $items = $spo_object->list_items(
#	'expand=fields(select=Title,StatusLookupId,id,AssignedTeamLookupId,RequestorClaims)',
	'expand=fields',
	'filter=fields/StatusLookupId eq \'1\' and fields/AssignedTeamLookupId eq \'4\' and startswith(fields/Title, \'Mutatie\')'
);

say Dumper $items;

my $payload = {
  "fields" => {
    'SLAPriorityLookupId' => '5',
    'StatusLookupId' => '1',
    'TicketType' => 'Incident',
	'RequesterLookupId' => '12',
	'AssignedTeamLookupId' => '4',
	'Origin' => 'Self Service',
	'Title'	=> 'Mutatie: b_enditisweergraph',
	'Description' => '<p>Dit ticket is via graph gemaakt als test</p>'
  }
};

my $result = $spo_object->list_item_create($payload);
say Dumper $result;

# SLAPriorityLookupId Priority Id 5
# StatusLookupId Status Id (1 is new)
# TicketType TicketType Value Incident
#  Requester Claims responder email
# AssignedTeamLookupId Assigned Team Id (4 is account team)
# Origin Omni Channel Value Self Service
# Description Description bla bla bla

