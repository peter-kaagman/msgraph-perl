package MsUser;

use v5.11;
use Moose;
use LWP::UserAgent;
use JSON;
use Data::Dumper;

extends 'MsGraph';

# Attributes 
has 'id' => (
	is => 'ro', 
	isa => 'Str', 
	required => '1',
	reader => '_get_id',
	writer => '_set_id',
);
#

sub fetch_id_by_upn { #	{{{1
	my $self = shift;
	my $upn = shift;
	my %user_info;
	my $url = $self->_get_graph_endpoint . "/v1.0/users/$upn". '?$select=id';
	#say "Fetching id for $url";
	my $result = $self->callAPI($url, 'GET');
	if ($result->is_success){
		my $content = decode_json($result->{'_content'});
		return $content->{'id'};
	}else{
		#print Dumper $result;
		return 'onbekend';
	}
}#	}}}

sub eduUser_set_role {
	my $self = shift;
	my $role = shift;
	my $payload = {
		"primaryRole" => $role,
	};
    my $url = $self->_get_graph_endpoint . '/v1.0/education/users/'.$self->_get_id;
	my $result = $self->callAPI($url, 'PATCH', $payload);
}

sub user_groups {
	my $self = shift;
    my @parameters;
    push(@parameters,$self->_get_filter) if ($self->_get_filter);
    push(@parameters,$self->_get_select) if ($self->_get_select);

    #my $url = $self->_get_graph_endpoint . '/v1.0/users/'?";

    my $url = $self->_get_graph_endpoint . '/v1.0/users/'. $self->_get_id. '/memberOf/?'. join( '&', @parameters);
	my @groups;
	$self->fetch_list($url, \@groups);
	return \@groups;

}

sub user_update {
	my $self = shift;
	my $payload = shift;

    my $url = $self->_get_graph_endpoint . '/v1.0/users/' . $self->_get_id;
	my $result = $self->callAPI($url,'PATCH',$payload);
	return $result;

}

__PACKAGE__->meta->make_immutable;
42;
# vim: set foldmethod=marker