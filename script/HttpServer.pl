#!/usr/bin/perl

use strict;
use URI::Escape;
use Try::Tiny;
use Data::Dumper;
use Mojolicious::Lite;
use Search::Elasticsearch;

my $index = 'callserv_call_nuance_en';
my $es = Search::Elasticsearch->new(nodes=>['192.168.1.20:9200'], cxn_pool => 'Sniff');

post '/result' => sub
{
	my $self = shift;
	my $result = $self->req->json;
	my $reference = $result->{reference};	
	my $text = 'NULL';
	my $length = 0;
	my $error_info = 0;

	try
	{
		$error_info = scalar(@{$result->{channels}->{channel1}->{errors}});
	}
	catch
	{
		$error_info = scalar(@{$result->{errors}});
	};

	if($error_info > 0)
	{
		$text = 'NULL';
	}
	else
	{
		$text = $result->{channels}->{channel1}->{transcript}->[0]->{text};
		$length = $result->{channels}->{channel1}->{statistics}->{audio_length};
	}
	
	my $results = $es->search(index => $index, body => {query => {match => {reference => $reference}}});
	my $wavname = $results->{hits}->{hits}->[0]->{_source}->{wavname};
	my $server = $results->{hits}->{hits}->[0]->{_source}->{server};
	
	print $wavname.":".$reference.":".$text.":".$length."\n" if $text and $wavname;	

	if($wavname)
	{
		$es->index(index => $index,
			    type => 'data',
		 	     id  => $wavname,
		 	    body => {
				wavname => $wavname,
	    	     	      reference => $reference,
				   text => $text,
				 server => $server,
			         length => $length
				}
			);
	}
};
	
app->start;
