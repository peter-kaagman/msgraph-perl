#! /usr/bin/env perl

# Default module imports
use strict;     # Altijd goed om strict en warnings te gebruiken
use warnings;
use v5.11;      # Gebruik v5.11 voor onderandere de 'say' functie

# Specifieke module imports voor dit script
use Data::Dumper;           # Handig voor debuggen, hiermee kun je complexe datastructuren mooi printen
use Config::Simple;         # Om makkelijk configuratiebestanden te kunnen lezen
use Time::Piece;            # Voor het werken met datums en tijden
use FindBin;                # Om het pad van het script te kunnen gebruiken, handig voor het vinden van config bestanden en libraries
use lib "$FindBin::Bin/lib";# Voeg de 'lib' directory toe aan @INC zodat we onze eigen modules kunnen gebruiken

# Eigen modules voor specifieke functionaliteit
use MsGraph;                # Eigen module voor het werken met Microsoft Graph API
                            # Deze module staat in de 'lib' directory en bevat generiek MS Graph functionaliteit.

# Initialisatie van de configuratie
my %config;                # Hash om de configuratie in op te slaan
# Lees de configuratie uit azure.cfg, als dat niet lukt, geef een foutmelding en stop het script
Config::Simple->import_from("$FindBin::Bin/azure.cfg",\%config) or die("No config: $!"); 

# Maak een nieuw MsGraph object aan met de configuratie parameters
my $ms_graph = MsGraph->new(
    'app_id'        => $config{'APP_ID'},         # De applicatie ID
    'app_secret'    => $config{'APP_PASS'},       # Het applicatie wachtwoord
    'tenant_id'     => $config{'TENANT_ID'},      # De tenant ID
    'login_endpoint'=> $config{'LOGIN_ENDPOINT'}, # De login endpoint URL
    'graph_endpoint'=> $config{'GRAPH_ENDPOINT'}, # De Graph API endpoint URL
);
# Probeer een access token te krijgen, als dat lukt, print het token, anders geef een foutmelding
if ($ms_graph->_get_access_token){
    say "Access token: ", $ms_graph->access_token; # Print het access token
} else {
    say "Fout bij het verkrijgen van access token";# Foutmelding als het niet lukt
}