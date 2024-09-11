package MsSpoList;

use v5.11;
use Moose;
use LWP::UserAgent;
use JSON;
use Data::Dumper;

extends 'MsGraph';

# Attributes
has 'site_id'     => (
	is => 'rw', 
	isa => 'Str', 
	required => '0',
	reader => '_get_site_id',
	writer => '_set_site_id',
);

has 'site_naam'     => (
	is => 'rw', 
	isa => 'Str', 
	required => '0',
	reader => '_get_site_naam',
	writer => '_set_site_naam',
);

has 'list_id'     => (
	is => 'rw', 
	isa => 'Str', 
	required => '0',
	reader => '_get_list_id',
	writer => '_set_list_id',
);

has 'list_naam'     => (
	is => 'rw', 
	isa => 'Str', 
	required => '0',
	reader => '_get_list_naam',
	writer => '_set_list_naam',
);

augment 'BUILD' => sub {
    my $self = shift;
    #say "Dit is augmented in MsSpoList";
    # Site eerst maar, id nodig om de list te kunnen vinden
    # Als er geen site_id is opgegeven dan de id via de naam zoeken
    if (! $self->_get_site_id){
        # Dan moet er wel een naam zijn
        if ($self->_get_site_naam){
            my $site_id = $self->site_id_by_naam($self->_get_site_naam);
            if ($site_id){
                $self->_set_site_id($site_id);
            }else{
                die("Kan geen site id vinden voor ",$self->_get_site_naam);
            }
        }else{
            die("Geen sitenaam en geen id, ik geef het op.");
        }
    }
    # Nu we de site id hebben verder met de list
    # Als er geen list_id is opgegeven dan de id via de naam zoeken
    if (! $self->_get_list_id){
        # Dan moet er wel een naam zijn
        if ($self->_get_list_naam){
            my $list_id = $self->list_id_by_naam($self->_get_list_naam);
            if ($list_id){
                $self->_set_list_id($list_id);
            }else{
                die("Kan geen list id vinden voor ",$self->_get_list_naam);
            }
        }else{
            die("Geen lijstnaam en geen id, ik geef het op.");
        }
    }
};

sub site_id_by_naam {
    my $self = shift;
    my $naam = shift;
    my @sites;
    my $url = $self->_get_graph_endpoint . "/v1.0/sites/?search=$naam";

    # Hier komt een collectie op terug dus getList gebruiken
    # Als de site subsites heeft dan zijn er sowieso meerdere resultaten
    # matchen op de name property
    my $result = $self->fetch_list($url,\@sites);
    if ($result){
        my $found = 0;
        foreach my $site (@sites){
            if ($site->{'name'} =~ /^$naam$/i){
                $found = $site->{'id'}
            }
            last if ($found);
        }
        return $found;
    } else{
        warn("Kan geen site id vinden voor ",$self->_get_site_naam," zie ook de console voor fouten.");
        return 0;
    }
}

sub list_id_by_naam {
    my $self = shift;
    my $naam = shift;
    my @lists;
    my $url = $self->_get_graph_endpoint . '/v1.0/sites/';
    $url .= $self->_get_site_id;
    $url .= '/lists';
    $url .= '?$select=id,displayName';
    # Hier komt een collectie op terug dus getList gebruiken
    my $result = $self->fetch_list($url,\@lists);
    if ($result){
        my $found = 0;
        foreach my $list (@lists){
            if ($list->{'displayName'} =~ /^$naam$/i){
                $found = $list->{'id'};
            }
            last if ($found);
        }
        return $found;
    } else{
        warn("Kan geen list id vinden voor ",$self->_get_list_naam," zie ook de console voor fouten.");
        return 0;
    }
}

sub list_items {
	my $self = shift;
    my $fields = shift;
    my $filter = shift;
	my @items;

	my @parameters;
    push(@parameters,$fields) if ($fields);
    push(@parameters,$filter) if ($filter);
	# compose an URL
	my $url = $self->_get_graph_endpoint . '/v1.0/sites/';
	$url .= $self->_get_site_id;
	$url .= '/lists/';
	$url .= $self->_get_list_id;
	$url .= '/items?';
    $url .= join('&',@parameters);
    #expand=fields&filter=fields/StatusLookupId eq \'1\'';
	#$url .= '/items?expand=fields(select=Title,StatusLookupId,id)&filter=fields/StatusLookupId eq \'1\'';
	#$url .= '/items?expand=fields(select=Title,StatusLookupId)&filter=startswith(fields/Title, \'Uit dienst:\')';
	# Hier komt een collectie op terug dus getList gebruiken
	my $result = $self->fetch_list($url,\@items);
	my $return;
	foreach my $ticket (@items){
        while (my($fieldname,$fieldcontent) = each %{$ticket->{'fields'}}){
            #say "$ticket->{'id'} $fieldname $fieldcontent";
		    $return->{$ticket->{'id'}}->{$fieldname} = $fieldcontent;
        }
	}
	return $return;
}

sub list_item_create {
    my $self = shift;
    my $payload = shift;
	my $url = $self->_get_graph_endpoint . '/v1.0/sites/';
	$url .= $self->_get_site_id;
	$url .= '/lists/';
	$url .= $self->_get_list_id;
	$url .= '/items';
    my $result = $self->callAPI($url,'POST',$payload);
}

__PACKAGE__->meta->make_immutable;
42;
