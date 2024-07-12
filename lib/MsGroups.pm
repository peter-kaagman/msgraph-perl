package MsGroups;

use v5.10;

use Moose;
use LWP::UserAgent;
use JSON;
use Data::Dumper;
#use Mojo::JSON qw(decode_json encode_json);

extends 'MsGraph';

# Attributes {{{1

# }}}

sub groups_fetch { #	{{{1
	my $self = shift;
	my @groups;
	my $url = $self->_get_graph_endpoint . "/v1.0/groups/?";
	if ($self->_get_filter){
		$url .= $self->_get_filter."&";
	}
	if ($self->_get_select){
		$url .= $self->_get_select."&";
	}
	#say "Fetching $url";
	$self->fetch_list($url, \@groups);
	return  \@groups;
	
}#	}}}

sub group_create {
	my $self = shift;
	my $group_info = shift;
	# callAPI uit msGraph.pm voldoet in dit geval niet
	# die is niet voorzien om data te sturen
	# wellicht tot een nieuwe generieke methode komen voor dit doel of aanpassen?
	my $url = $self->_get_graph_endpoint . "/v1.0/groups";
	my $ua = LWP::UserAgent->new(		# Create a LWP useragnent (beyond my scope, its a CPAN module)
		'timeout' => '180',
	);
	# Create the header
	my $header =	[
		'Accept'        => '*/*',
		'Authorization' => "Bearer ".$self->_get_access_token,
		'Content-Type'  => 'application/json',
		'Consistencylevel' => $self->_get_consistencylevel
	];
	my $data = encode_json($group_info);
	# Create the request
	my $r  = HTTP::Request->new(
		'POST',
		$url,
		$header,
		$data,
	);	
	#print Dumper $r;
	# Let the useragent make the request
	my $result = $ua->request($r);
	return $result;

}


# Dit is bedoeld voor groepen, niet voor teams
sub group_add_member {
	my $self = shift;
	my $group_id = shift;
	my $member_id = shift;
	my $member = {
		'@odata.id' => "https://graph.microsoft.com/v1.0/directoryObjects/$member_id"
	};
	my $url = $self->_get_graph_endpoint . '/v1.0/groups/'.$group_id.'/members/$ref';
	my $result = $self->callAPI($url,'POST',$member);
	if ($result->is_success){
		sleep(1); #vlgs de doc ff wachten na het toevoegen van een gebruiker
		return "Ok";
	}else{
		return "RC $result->{'_rc'}: $result->{'_content'}";
	}
}

# Dit is voor groepen, teams anders doen
sub group_add_owner {
	my $self = shift;
	my $group_id = shift;
	my $owner_id = shift;
	# Een owner moet ook member zijn
	my $member_reply = $self->group_add_member($group_id,$owner_id);
	if ( $member_reply eq 'Ok'){
		my $owner = {
			'@odata.id' => "https://graph.microsoft.com/v1.0/directoryObjects/$owner_id"
		};
		my $url = $self->_get_graph_endpoint . '/v1.0/groups/'.$group_id.'/owners/$ref';
		my $result = $self->callAPI($url, 'POST', $owner);
		if ($result->is_success){
			sleep(1); #vlgs de doc ff wachten na het toevoegen van een gebruiker
			return "Ok";
		}else{
			return "RC $result->{'_rc'}: $result->{'_content'}";
		}
	}else{
		return "Error adding owner as member RC $member_reply->{'_rc'}: $member_reply->{'_content'}";
	}
}

sub group_find_id {
	my $self = shift;
	my $name = shift;
	my $url = $self->_get_graph_endpoint . '/v1.0/groups?$select=id&$filter=startswith(mailNickname,\''.$name.'\')';
	my $result = $self->callAPI($url, 'GET');
	if ($result->is_success){
		#print Dumper $result;
		my $json = decode_json($result->{'_content'});
		#say $json->{'value'}[0]->{'id'};
		return $json->{'value'}[0]->{'id'};
	}else{
	        say $url;
		die $result->decoded_content;
	}

}

sub group_list {
	my $self = shift;
	my @groups;
	my @parameters;
    push(@parameters,$self->_get_filter) if ($self->_get_filter);
    push(@parameters,$self->_get_select) if ($self->_get_select);
    #push(@parameters,'$count=true');
    
    my $url = $self->_get_graph_endpoint . "/v1.0/groups/?". join( '&', @parameters);
    $self->fetch_list($url,\@groups);
    return \@groups;
}


#
# Teams related
#
sub teams_fetch { #	{{{1
	my $self = shift;
	my @teams;
	my $url = $self->_get_graph_endpoint . "/v1.0/teams/?";
	if ($self->_get_filter){
		$url .= $self->_get_filter."&";
	}
	if ($self->_get_select){
		$url .= $self->_get_select."&";
	}
	$self->fetch_list($url, \@teams);
	return  \@teams;
	
}#	}}}

sub team_create {
	my $self = shift;
	my $team_info = shift;
	my $url = $self->_get_graph_endpoint . "/v1.0/teams";
	my $result = $self->callAPI($url, 'POST', $team_info);
	return $result;
}

sub team_archive {
	# Om gegevens verlies te voorkomen worden teams niet verwijdert maar gearchiveerd.
	# Archiveren is een async operatie, duurt een eeuwigheid, description daarom ook aan-
	# passen zodat het archiveren direct duidelijk is en de group ook herkenbaar is als 
	# zijnde gearchiveerd. Een groups heeft die property namelijk niet.
	# mailNick wordt ook aangepast zodat het team niet meer opduikt in een teams listing.
	my $self = shift;
	my $team_id = shift;
	my $team_naam = shift;
	my $url = $self->_get_graph_endpoint . "/v1.0/teams/$team_id/archive";
	my $result = $self->callAPI($url, 'POST');
	if ($result->is_success){
		# archiveren is geslaagd => description aanpassen
		# dit is een PATCH
		$url = $self->_get_graph_endpoint . "/v1.0/groups/$team_id";
		# ToDo: Dit is een module en er staat EduTeam => niet generiek
		my $payload = {
			"description" => 'Archived_'.$team_naam,
			"displayName" => 'Archived_'.$team_naam,
			"mailNickname"=> 'Archived_EduTeam_'.$team_naam,
		};
		my $result = $self->callAPI($url, 'PATCH', $payload);
		if ($result->is_success){
			return "Ok";
		}else{
			return $result;
		}
	}
}
sub team_dearchive {
	# Om gegevens verlies te voorkomen worden teams niet verwijdert maar gearchiveerd.
	# Archiveren is een async operatie, duurt een eeuwigheid, description daarom ook aan-
	# passen zodat het archiveren direct duidelijk is en de group ook herkenbaar is als 
	# zijnde gearchiveerd. Een groups heeft die property namelijk niet.
	# mailNick wordt ook aangepast zodat het team niet meer opduikt in een teams listing.
	my $self = shift;
	my $team_id = shift;
	my $payload = shift;
	my $url = $self->_get_graph_endpoint . "/v1.0/teams/$team_id/unarchive";
	my $result = $self->callAPI($url, 'POST');
	if ($result->is_success){
		# archiveren is geslaagd => description aanpassen
		# dit is een PATCH
		$url = $self->_get_graph_endpoint . "/v1.0/groups/$team_id";
		my $result = $self->callAPI($url, 'PATCH', $payload);
		return $result;
	}else{
		return $result;
	}
}

sub team_is_archived {
	my $self = shift;
	my $team_naam = shift;
	my $url = $self->_get_graph_endpoint . "/v1.0/groups";
	$url .= '?$select=id';
	# ToDo Dit is een module => EduTeam hier noemen is niet generiek
	$url .= "&\$filter=mailNickname eq '$team_naam'";
	my $result = $self->callAPI($url, 'GET');
	if ($result->is_success){
		my $content = decode_json($result->decoded_content);
		if ($content->{'value'}[0]->{'id'}){
			return $content->{'value'}[0]->{'id'}
		}else{
			return 0;
		}
	}else{
		warn $result->message;
		return 0;
	}

}



#
# Class related
#
sub class_create {
	my $self = shift;
	my $class_info = shift;
	my $url = $self->_get_graph_endpoint . "/v1.0/education/classes";
	my $result = $self->callAPI($url, 'POST', $class_info);
	return $result;

}

sub classes_fetch{
	my $self = shift;
	my @classes;
	my $url = $self->_get_graph_endpoint . "/v1.0/education/classes/?";
	if ($self->_get_filter){
		$url .= $self->_get_filter."&";
	}
	if ($self->_get_select){
		$url .= $self->_get_select."&";
	}
	$self->fetch_list($url, \@classes);
	return  \@classes;
}




__PACKAGE__->meta->make_immutable;
42;
