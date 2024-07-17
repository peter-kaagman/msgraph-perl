#! /usr/bin/env perl

use strict;
use warnings;
use v5.11;

use Data::Dumper;
use Config::Simple;
use DBI;
use Time::Piece;
use Parallel::ForkManager;
use FindBin;
use lib "$FindBin::Bin/lib";

use MsGroups;
use MsGroup;
use Logger;


my %config;
Config::Simple->import_from("$FindBin::Bin/azure.cfg",\%config) or die("No config: $!");


my $groups_object = MsGroups->new(
	'app_id'        => $config{'APP_ID'},
	'app_secret'    => $config{'APP_PASS'},
	'tenant_id'     => $config{'TENANT_ID'},
	'login_endpoint'=> $config{'LOGIN_ENDPOINT'},
	'graph_endpoint'=> $config{'GRAPH_ENDPOINT'},
	#'filter'        => '$filter=startswith(mailNickname,\'Section_'.$config{'MAGISTER_LESPERIODE'}.'\')', # lesperiode in de select zodat alleen het huidige jaar opgehaald wordt
	'filter'        => '$filter=startswith(displayName,\'2324-0\')', # lesperiode in de select zodat alleen het huidige jaar opgehaald wordt
    'select'        => '$select=id,displayName,description,mailNickname',
);


my @maxen = qw(0 10 20 30 40);
foreach my $max (@maxen){
    my $par_aantal_teams;
    say "Run met max process op $max, eerst een sleep 60";
    #sleep 60;
    say "gaat ie";
    my $par_result;
    my $par_aantal_docenten;
    my $par_start = localtime->epoch;
    if ($groups_object->_get_access_token){
        say "Teams ophalen";
        my $teams = $groups_object->groups_fetch;
        #print Dumper $teams;
        $par_aantal_teams = scalar @{$teams};

        my $pm = Parallel::ForkManager->new($max);

        # Callback
        $pm->run_on_finish( sub{
            my ($pid,$exit_code,$ident,$exit,$core_dump,$members) = @_;
            # say "Dit is run_on_finish";
            # say "PID: ",$pid;
            # say "ExitCode: ",$exit_code;
            # say "ident: ",$ident;
            # say "Exit: ",$exit;
            # say "CoreDump: ",$core_dump;
            # say "Members voor $ident";
            #print Dumper $members;
            $par_result->{$ident} = $members;
        });

        MEMBERS:
        #while (my($upn, $docent) = each %{$docenten}){
        foreach my $team (@{$teams}){
            my $pid = $pm->start($team->{'displayName'}) and next MEMBERS; # FORK
            #say "In runner";
            my $group_object = MsGroup->new(
                'app_id'        => $config{'APP_ID'},
                'app_secret'    => $config{'APP_PASS'},
                'tenant_id'     => $config{'TENANT_ID'},
                'login_endpoint'=> $config{'LOGIN_ENDPOINT'},
                'graph_endpoint'=> $config{'GRAPH_ENDPOINT'},
                'select'        => '$select=id,displayName',
                'access_token'  => $groups_object->_get_access_token,
                'token_expires' => $groups_object->_get_token_expires,
                'id'            =>  $team->{'id'},
            );
            #print Dumper $team;
            my $members = $group_object->team_members;
            # my $doc_vakken = $session->getRooster($docent->{'stamnr'},"GetPersoneelGroepVakken");
            # # De eerste waarde in finish is de exit_code, de twee de data reference
            $pm->finish(23,$members); # exit child
        } 
        $pm->wait_all_children;
        say " done";
    }
    my $par_einde = localtime->epoch;
    my $par_duur = $par_einde - $par_start;
    # #print Dumper $par_result;
    #print Dumper $par_result;
    say "Parallel duurt $par_duur seconden";
    say "Teams opgehaald: $par_aantal_teams";
    say "Teams in result: ". scalar keys %{$par_result};
}