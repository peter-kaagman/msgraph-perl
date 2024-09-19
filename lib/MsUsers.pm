package MsUsers;
#
# Do "things" with groups of Azure users
#

use v5.11;
use Moose;
use LWP::UserAgent;
use JSON;
use Data::Dumper;

extends 'MsGraph';

# Attributes {{{1
# }}}

sub users_fetch {
    my $self = shift;
    my $showAll = shift;
    my @users;
    my @parameters;
    push(@parameters,$self->_get_select) if ($self->_get_select);
    # Voeg een filter toe op accountEnabled
    if ($self->_get_filter){
        if ($showAll){
            # _get_Filter en showAll -> alleen _get_filter dus
            push(@parameters,$self->_get_filter) if ($self->_get_filter);
        }else{
            # filteren op active en _get_filter -> filter combineren
            my $filter = $self->_get_filter . 'and accountEnabled eq true';
            push(@parameters, $filter);
        }
    }else{
        push(@parameters,'$filter=accountEnabled eq true') if (! $showAll);
    }

    
    my $url = $self->_get_graph_endpoint . "/v1.0/users/?". join( '&', @parameters);

    $self->fetch_list($url,\@users);
    return \@users;
}

sub users_fetch_deleted {
    my $self = shift;
    my @users;
    my @parameters;
    push(@parameters,$self->_get_filter) if ($self->_get_filter);
    push(@parameters,$self->_get_select) if ($self->_get_select);
    
    my $url = $self->_get_graph_endpoint . "/v1.0/directory/deletedItems/microsoft.graph.user?". join( '&', @parameters);

    $self->fetch_list($url,\@users);
    return \@users;
}

sub fetch_edusers {
    my $self = shift;
    my @users;
    my @parameters;
    push(@parameters,$self->_get_filter) if ($self->_get_filter);
    push(@parameters,$self->_get_select) if ($self->_get_select);
    
    my $url = $self->_get_graph_endpoint . "/v1.0/education/users/?". join( '&', @parameters);
    $self->fetch_list($url,\@users);
    return \@users;
}

sub user_create {
    my $self = shift;
    my $payload = shift;
    my $url = $self->_get_graph_endpoint . "/v1.0/users";
    my $result = $self->callAPI($url,'POST',$payload);
    return $result;
}
