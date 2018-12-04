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
	try
	{
		$text = $result->{channels}->{channel1}->{transcript}->[0]->{text};
	}
	catch
	{
		$text = 'NULL';
		print 'Error : '.$reference."\n";			
	};
	
	my $results = $es->search(index => $index, body => {query => {match => {_id => $reference}}});
	my $wavname = $results->{hits}->{hits}->[0]->{_source}->{wavname};

	print $wavname.":".$reference.":".$text."\n";	
	$es->index(index => $index,
		 type    => 'data',
		 id      => $reference,
		 body    => {
			wavname => $wavname,
		     reference  => $reference,
			   text => $text
			}
		);
};
	
app->start;
