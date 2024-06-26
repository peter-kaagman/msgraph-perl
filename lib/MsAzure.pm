package MsAzure;

use v5.11;
use Moose;
use JSON;
use Data::Dumper;

extends 'MsGraph';

# Attributes {{{1
# }}}

sub azure_get_apps{
    my $self = shift;
    my @apps;
    my @parameters;
    push(@parameters,$self->_get_filter) if ($self->_get_filter);
    push(@parameters,$self->_get_select) if ($self->_get_select);

    my $url = $self->_get_graph_endpoint . "/v1.0/applications/?". join( '&', @parameters);
    $self->fetch_list($url, \@apps);
    return \@apps;
}

