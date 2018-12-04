#!/usr/bin/perl

use strict;
use JSON;
use threads;
use Encode;
use Try::Tiny;
use Config::Tiny;
use LWP::UserAgent;
use Search::Elasticsearch;
use script::CallOuterServer;

if(scalar(@ARGV) != 2)
{
	print "Usage : perl $0 input.list threadnum\n";
	exit;
}

my $jsonparser = new JSON;
open(IN,$ARGV[0])||die("The file can't find!\n");

&Main();

sub Main
{
	my $threadnum = $ARGV[1];
	my @tasks = <IN>;
	my $group = div(\@tasks,$threadnum);
	my $param = init();
	my $es = Search::Elasticsearch->new(nodes=>['192.168.1.20:9200'], cxn_pool => 'Sniff');

	my @threads;
	foreach my $key (keys %$group)
	{
		my $thread = threads->create(\&dowork,$group->{$key},$param,$es);
		push @threads,$thread;
	}

	foreach(@threads)
	{
		$_->join();
	}
}

sub div
{
	my $ref = shift;
	my $threadnum = shift;

	my $res;
    	for(my $i = 0; $i < scalar(@$ref); $i++)
   	{
   		my $flag = $i%$threadnum;
   		push @{$res->{$flag}},$ref->[$i];
    	}

    	return $res;
}

sub init
{
	my $config = Config::Tiny->new;
	$config = Config::Tiny->read('config/config.ini', 'utf8');

	my $res;
	$res->{nuance_engine_url} = $config->{process_Wav_config}->{nuance_engine_url};
	$res->{fileserver_url} = $config->{process_Wav_config}->{fileserver_url};
	return $res;
}

sub dowork
{
	my $wavs = shift;
	my $param = shift;
	my $es = shift;

	my $engine_url = $param->{nuance_engine_url};
	my $fileserver_url = $param->{fileserver_url};
	
	foreach my $wavname (@$wavs)
	{
		chomp($wavname);
		$wavname =~ s/^\s+|\s+$//g;
		
		my $index = 'callserv_call_nuance_en';
		my $results = $es->search(index => $index, body => {query => {match => {_id => $wavname}}});
		my $flag = $results->{hits}->{total};
		
		if($flag == 0)
		{
			my $reference = OuterServer::callNuanceEnglishAsrEngine($index,$es,$fileserver_url,$wavname,$engine_url);
			print $wav.'|'.$reference."\n";
		}
		else
		{
			my $text = $results->{hits}->{hits}->[0]->{_source}->{text};
			if($text)
			{
				my $reference = OuterServer::callNuanceEnglishAsrEngine($index,$es,$fileserver_url,$wavname,$engine_url);
				print $wav.'|'.$reference."\n";
			}
		}

		die;
	}
}

1;

