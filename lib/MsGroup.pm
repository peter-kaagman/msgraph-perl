package MsGroup;

use v5.10;

use Moose;
use LWP::UserAgent;
use JSON;
use Data::Dumper;

extends 'MsGraph';

# Attributes {{{1
has 'id' => ( # {{{2
	is => 'ro', 
	isa => 'Str', 
	required => '1',
	reader => '_get_id',
	writer => '_set_id',
); #}}}
has 'filter'         => ( # {{{2
	is => 'rw', 
	isa => 'Maybe[Str]', 
	required => '0',
	reader => '_get_filter',
	writer => '_set_filter',
); #}}}
has 'select'         => ( # {{{2
	is => 'rw', 
	isa => 'Maybe[Str]', 
	required => '0',
	reader => '_get_select',
	writer => '_set_select',
); #}}}
# }}}

sub do_fetch { # {{{1
	my $self = shift;
	my $url = shift;
	my $groups = shift;
	my $result = $self->callAPI($url, 'GET');
	if ($result->is_success){
		my $reply =  decode_json($result->decoded_content);
		while (my ($i, $el) = each @{$$reply{'value'}}) {
			push @{$groups}, $el;
		}
		if ($$reply{'@odata.nextLink'}){
			do_fetch($self,$$reply{'@odata.nextLink'}, $groups);
		}
		#print Dumper $$reply{'value'};
	}else{
		print Dumper $result;
		die $result->status_line;
	}
} #	}}}

sub fetch_owners { #	{{{1
	my $self = shift;
	my @owners;
	my $url = $self->_get_graph_endpoint . "/v1.0/groups/".$self->_get_id."/owners/?";
	if ($self->_get_filter){
		$url .= $self->_get_filter."&";
	}
	if ($self->_get_select){
		$url .= $self->_get_select."&";
	}
	#say "Fetching $url";
	do_fetch($self,$url, \@owners);
	return  \@owners;
	
}#	}}}

__PACKAGE__->meta->make_immutable;
42;
# vim: set foldmethod=marker